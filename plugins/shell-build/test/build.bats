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

@test "yaml is installed for shell" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "shell-3.6.2"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply shell patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "shell-3.6.2"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<""
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p0 --force -i $TMP/shell-patch.XXX
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply shell patch from git diff before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "shell-3.6.2"

  stub uname '-s : echo Linux'
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  # shenv/shenv#1026
  stub uname false false

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<"diff --git a/script.py"
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/shell-patch.XXX
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "shell-3.6.2"

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo Linux'
  stub brew "--prefix libyaml : echo '$brew_libdir'" false
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I$brew_libdir/include -I${TMP}/install/include " LDFLAGS="-L$brew_libdir/lib -L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "shell-3.6.2"

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"

  # shenv/shenv#1026
  stub uname false false

  stub brew "--prefix readline : echo '$readline_libdir'"
  stub_make_install

  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I$readline_libdir/include -I${TMP}/install/include " LDFLAGS="-L$readline_libdir/lib -L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is not linked from Homebrew when explicitly defined" {
  cached_tarball "shell-3.6.2"

  # shell-build
  readline_libdir="$TMP/custom"
  mkdir -p "$readline_libdir/include/readline"
  touch "$readline_libdir/include/readline/rlconf.h"

  # shenv/shenv#1026
  stub uname false false

  stub brew
  stub_make_install

  export SHELL_CONFIGURE_OPTS="CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib"
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub brew
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores defaults to 2" {
  cached_tarball "shell-3.6.2"

  # pyenv/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin' false
  stub sysctl false
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "shell-3.6.2"

  # pyenv/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin' false
  stub sysctl '-n hw.ncpu : echo 4'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  cached_tarball "shell-3.6.2"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo FreeBSD' false
  stub sysctl '-n hw.ncpu : echo 1'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 1
make install
OUT
}

@test "setting SHELL_MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "shell-3.6.2"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo Linux'
  stub_make_install

  export SHELL_MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install DOGE="such wow"
OUT
}

@test "setting MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "shell-3.6.2"

  # shenv/shenv#1026
  stub uname false false

  stub uname '-s : echo Linux'
  stub_make_install

  export MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
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
  cached_tarball "shell-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 9.1" false

  # shenv/shenv#1026
  stub uname false false

  MAKE=gmake stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub gmake
  unstub uname
}

@test "make on FreeBSD 10" {
  cached_tarball "shell-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 10.0-RELEASE" false

  # shenv/shenv#1026
  stub uname false false

  stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub uname
}

@test "make on FreeBSD 11" {
  cached_tarball "shell-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 11.0-RELEASE" false

  # shenv/shenv#1026
  stub uname false false

  stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub uname
}

@test "can use SHELL_CONFIGURE to apply a patch" {
  cached_tarball "shell-3.6.2"

  executable "${TMP}/custom-configure" <<CONF
#!$BASH
apply -p1 -i /my/patch.diff
exec ./configure "\$@"
CONF

  stub uname '-s : echo Linux'
  stub apply 'echo apply "$@" >> build.log'
  stub_make_install

  # pyenv/pyenv#257
  stub uname '-s : echo Linux'
  stub uname '-s : echo Linux'

  export SHELL_CONFIGURE="${TMP}/custom-configure"
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub apply

  assert_build_log <<OUT
apply -p1 -i /my/patch.diff
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
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

@test "mruby strategy overwrites non-writable files" {
  # nop
}

@test "mruby strategy fetches rake if missing" {
  # nop
}

@test "rbx uses bundle then rake" {
  # nop
}

@test "fixes rbx binstubs" {
  # nop
}

@test "JRuby build" {
  # nop
}

@test "JRuby+Graal does not install launchers" {
  # nop
}

@test "JRuby Java 7 missing" {
  # nop
}

@test "JRuby Java is outdated" {
  # nop
}

@test "JRuby Java 7 up-to-date" {
  # nop
}

@test "Java version string not on first line" {
  # nop
}

@test "Java version string on OpenJDK" {
  # nop
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
  cached_tarball "shell-3.6.2"

  export LDFLAGS="-L ${BATS_TEST_DIRNAME}/what/evs"
  run_inline_definition <<DEF
install_package "shell-3.6.2" "http://shell.org/ftp/shell/3.6.2/shell-3.6.2.tar.gz" ldflags_dirs
DEF
  assert_success

  assert [ -d "${INSTALL_ROOT}/lib" ]
  assert [ -d "${BATS_TEST_DIRNAME}/what/evs" ]
}
