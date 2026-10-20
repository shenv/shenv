#!/usr/bin/env bats

load test_helper
export SHELL_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc
export -n SHELL_CONFIGURE_OPTS

setup() {
  ensure_not_found_in_path aria2c
  mkdir -p "$INSTALL_ROOT"
  stub md5 false
  stub curl false

  # Keep checksum detection from consuming Homebrew stubs on hosts without shasum.
  stub shasum true
}

executable() {
  local file="$1"
  mkdir -p "${file%/*}"
  cat > "$file"
  chmod +x "$file"
}

cached_tarball() {
  mkdir -p "$SHELL_BUILD_CACHE_PATH"
  pushd "$SHELL_BUILD_CACHE_PATH" >/dev/null
  tarball "$@"
  popd >/dev/null
}

tarball() {
  local name="$1"
  local path="$PWD/$name"
  local configure="$path/configure"
  shift 1

  executable "$configure" <<OUT
#!$BASH
echo "$name: CPPFLAGS=\\"\$CPPFLAGS\\" LDFLAGS=\\"\$LDFLAGS\\"" >> build.log
echo "$name: \$@" \${SHELLOPT:+SHELLOPT=\$SHELLOPT} >> build.log
OUT

  for file; do
    mkdir -p "$(dirname "${path}/${file}")"
    touch "${path}/${file}"
  done

  tar czf "${path}.tar.gz" -C "${path%/*}" "$name"
}

stub_make_install() {
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    "install : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

@test "Bash release outside upstream support warns and still builds" {
  cached_tarball "bash-4.4"
  stub shasum "echo d86b3392c1202e8ff5a423b302e6284db7f8f435ea9f39b5b1b20fd3ac36dfcb"
  stub_make_install

  run shell-build "bash-4.4" "$INSTALL_ROOT"

  assert_success
  assert_output_contains "WARNING: bash-4.4 is past its end of life and is now unsupported."
  assert_output_contains "It no longer receives bug fixes or critical security updates."
  unstub make
  unstub shasum

  # Adding a warning must preserve the default configure, build, and install steps.
  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "superseded bundled prerelease warns and still builds" {
  cached_tarball "bash-5.2-alpha"
  stub shasum "echo 5da1ce90054f17fde5f9b15d56581be55b51be28d0f9cd8b36a776db4f4af006"
  stub_make_install

  run shell-build "bash-5.2-alpha" "$INSTALL_ROOT"

  assert_success
  assert_output_contains "WARNING: bash-5.2-alpha is past its end of life and is now unsupported."
  unstub make
  unstub shasum
}

@test "Bash 5.2 warns after upstream moves support to Bash 5.3" {
  cached_tarball "bash-5.2.15"
  stub shasum "echo 13720965b5f4fc3a0d4b61dd37e7565c741da9a5be24edc2ae00182fc1b3588c"
  stub_make_install

  run shell-build "bash-5.2.15" "$INSTALL_ROOT"

  assert_success
  assert_output_contains "WARNING: bash-5.2.15 is past its end of life and is now unsupported."
  unstub make
  unstub shasum
}

@test "shell without a verified EOL policy builds without a warning" {
  # A newer release alone does not establish an upstream end-of-life policy.
  cached_tarball "fish-2.7.0"
  stub shasum "echo 3a76b7cae92f9f88863c35c832d2427fb66082f98e92a02203dc900b8fa87bcb"
  stub_make_install

  run shell-build "fish-2.7.0" "$INSTALL_ROOT"

  assert_success
  refute grep -q "WARNING:" <<<"$output"
  unstub make
  unstub shasum
}

@test "yaml is installed for shell" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "bash-4.4"

  stub brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply shell patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "bash-4.4"

  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<""
  assert_success

  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p0 --force -i $TMP/shell-patch.XXX
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply shell patch from git diff before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "bash-4.4"

  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<"diff --git a/script.py"
  assert_success

  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/shell-patch.XXX
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "bash-4.4"

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  # rbenv/rbenv#1026
  stub uname false

  stub brew "--prefix libyaml : echo '$brew_libdir'" false
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I$brew_libdir/include -I${TMP}/install/include " LDFLAGS="-L$brew_libdir/lib -L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "bash-4.4"

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  # rbenv/rbenv#1026
  stub uname false

  stub brew "--prefix readline : echo '$readline_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I$readline_libdir/include -I${TMP}/install/include " LDFLAGS="-L$readline_libdir/lib -L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is not linked from Homebrew when explicitly defined" {
  cached_tarball "bash-4.4"

  # shell-build
  readline_libdir="$TMP/custom"
  mkdir -p "$readline_libdir/include/readline"
  touch "$readline_libdir/include/readline/rlconf.h"

  # rbenv/rbenv#1026
  stub uname false

  # An explicit readline path must not trigger a Homebrew lookup.
  stub brew
  stub_make_install

  export SHELL_CONFIGURE_OPTS="CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib"
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores defaults to 2" {
  cached_tarball "bash-4.4"

  # pyenv/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'
  stub uname '-s : echo Darwin'
  stub sysctl false
  stub_make_install

  unset MAKE_OPTS
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "bash-4.4"

  # pyenv/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'
  stub uname '-s : echo Darwin'
  stub sysctl '-n hw.ncpu : echo 4'
  stub_make_install

  unset MAKE_OPTS
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  stub uname false '-s : echo FreeBSD'
  stub sysctl '-n hw.ncpu : echo 1'

  run_inline_definition <<DEF
num_cpu_cores
DEF
  assert_success "1"

  unstub uname
  unstub sysctl
}

@test "setting SHELL_MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "bash-4.4"

  # rbenv/rbenv#1026
  stub uname false

  stub_make_install

  export SHELL_MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install DOGE="such wow"
OUT
}

@test "setting MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "bash-4.4"

  # rbenv/rbenv#1026
  stub uname false

  stub_make_install

  export MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install DOGE="such wow"
OUT
}

@test "custom relative install destination" {
  export SHELL_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  cd "$TMP"
  install_fixture definitions/without-checksum ./here
  assert_success
  assert [ -x ./here/bin/package ]
}

@test "make on FreeBSD 9 defaults to gmake" {
  cached_tarball "bash-4.4"

  stub uname "-s : echo FreeBSD" "-r : echo 9.1" false

  MAKE=gmake stub_make_install

  MAKE= install_fixture definitions/vanilla-shell
  assert_success

  unstub gmake
  unstub uname
}

@test "make on FreeBSD 10" {
  cached_tarball "bash-4.4"

  stub uname "-s : echo FreeBSD" "-r : echo 10.0-RELEASE" false

  stub_make_install

  MAKE= install_fixture definitions/vanilla-shell
  assert_success

  unstub uname
}

@test "make on FreeBSD 11" {
  cached_tarball "bash-4.4"

  stub uname "-s : echo FreeBSD" "-r : echo 11.0-RELEASE" false

  stub_make_install

  MAKE= install_fixture definitions/vanilla-shell
  assert_success

  unstub uname
}

@test "can use SHELL_CONFIGURE to apply a patch" {
  cached_tarball "bash-4.4"

  executable "${TMP}/custom-configure" <<CONF
#!$BASH
apply -p1 -i /my/patch.diff
exec ./configure "\$@"
CONF

  stub apply 'echo apply "$@" >> build.log'
  stub_make_install

  stub uname '-s : echo Linux'

  export SHELL_CONFIGURE="${TMP}/custom-configure"
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub apply

  assert_build_log <<OUT
apply -p1 -i /my/patch.diff
bash-4.4: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
bash-4.4: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "copy strategy forces overwrite" {
  export SHELL_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  mkdir -p "$INSTALL_ROOT/bin"
  touch "$INSTALL_ROOT/bin/package"
  chmod -w "$INSTALL_ROOT/bin/package"

  install_fixture definitions/without-checksum
  assert_success

  run "$INSTALL_ROOT/bin/package" "world"
  assert_success "hello world"
}

@test "non-writable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -w "$TMPDIR"

  touch "${TMP}/build-definition"
  run shell-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "shell-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}

@test "non-executable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -x "$TMPDIR"

  touch "${TMP}/build-definition"
  run shell-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "shell-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}

@test "initializes LDFLAGS directories" {
  cached_tarball "bash-4.4"

  export LDFLAGS="-L ${BATS_TEST_DIRNAME}/what/evs"
  run_inline_definition <<DEF
install_package "bash-4.4" "https://ftpmirror.gnu.org/bash/bash-4.4.tar.gz" ldflags_dirs
DEF
  assert_success

  assert [ -d "${INSTALL_ROOT}/lib" ]
  assert [ -d "${BATS_TEST_DIRNAME}/what/evs" ]
}
