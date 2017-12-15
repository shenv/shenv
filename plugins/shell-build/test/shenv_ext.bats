#!/usr/bin/env bats

load test_helper
export SHELL_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc

export TMP_FIXTURES="$TMP/fixtures"

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

install_patch() {
  local name="$1"
  local patch="$2"
  [ -n "$patch" ] || patch="shell.patch"

  mkdir -p "${TMP_FIXTURES}/${name%/*}/patches/${name##*/}/${patch%/*}"
  cat > "${TMP_FIXTURES}/${name%/*}/patches/${name##*/}/${patch}"
}

install_tmp_fixture() {
  local args

  while [ "${1#-}" != "$1" ]; do
    args="$args $1"
    shift 1
  done

  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  # Copy fixture to temporary path
  mkdir -p "${TMP_FIXTURES}/${name%/*}"
  cp "${FIXTURE_ROOT}/${name}" "${TMP_FIXTURES}/${name}"

  run shell-build $args "$TMP_FIXTURES/$name" "$destination"
}

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

@test "apply built-in shell patch before building" {
  cached_tarball "shell-3.6.2"

  stub brew false
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  echo | install_patch definitions/vanilla-python "shell-3.6.2/empty.patch"

  # pyenv/pyenv#257
  stub uname '-s : echo Linux'
  stub uname '-s : echo Linux'

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch -p0 --force -i $TMP/shell-patch.XXX
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "apply built-in shell patches should be sorted by its name" {
  cached_tarball "shell-3.6.2"

  stub brew false
  stub_make_install
  stub patch ' : for arg; do [[ "$arg" == "-"* ]] || sed -e "s/^/patch: /" "$arg"; done >> build.log'

  echo "foo" | install_patch definitions/vanilla-python "shell-3.6.2/foo.patch"
  echo "bar" | install_patch definitions/vanilla-python "shell-3.6.2/bar.patch"
  echo "baz" | install_patch definitions/vanilla-python "shell-3.6.2/baz.patch"

  # pyenv/pyenv#257
  stub uname '-s : echo Linux'
  stub uname '-s : echo Linux'

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch: bar
patch: baz
patch: foo
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "allow custom make install target" {
  cached_tarball "shell-3.6.2"

  stub brew false
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    " : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"

  # pyenv/pyenv#257
  stub uname '-s : echo Linux'
  stub uname '-s : echo Linux'

  SHELL_MAKE_INSTALL_TARGET="altinstall" TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make altinstall
OUT

  unstub make
}

@test "enable framework" {
  mkdir -p "${INSTALL_ROOT}/shell.framework/Versions/Current/bin"
  touch "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3"
  chmod +x "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3"
  touch "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3.4"
  chmod +x "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3.4"
  touch "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3-config"
  chmod +x "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3-config"
  touch "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3.4-config"
  chmod +x "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell3.4-config"

  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'

  SHELL_CONFIGURE_OPTS="--enable-framework" TMPDIR="$TMP" run_inline_definition <<OUT
echo "SHELL_CONFIGURE_OPTS_ARRAY=(\${SHELL_CONFIGURE_OPTS_ARRAY[@]})"
verify_shell shell3.4
OUT
  assert_success
  assert_output <<EOS
SHELL_CONFIGURE_OPTS_ARRAY=(--libdir=${TMP}/install/lib --enable-framework=${TMP}/install)
EOS

  [ -L "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell" ]
  [ -L "${INSTALL_ROOT}/shell.framework/Versions/Current/bin/shell-config" ]
}

@test "enable universalsdk" {
  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'

  SHELL_CONFIGURE_OPTS="--enable-universalsdk" TMPDIR="$TMP" run_inline_definition <<OUT
echo "SHELL_CONFIGURE_OPTS_ARRAY=(\${SHELL_CONFIGURE_OPTS_ARRAY[@]})"
OUT
  assert_success
  assert_output <<EOS
SHELL_CONFIGURE_OPTS_ARRAY=(--libdir=${TMP}/install/lib --enable-universalsdk=/ --with-universal-archs=intel)
EOS
}

@test "enable custom unicode configuration" {
  cached_tarball "shell-3.6.2"

  stub brew false
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    " : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"

  SHELL_CONFIGURE_OPTS="--enable-unicode=ucs2" TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
shell-3.6.2: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
shell-3.6.2: --prefix=$INSTALL_ROOT --enable-unicode=ucs2 --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
}

@test "default MACOSX_DEPLOYMENT_TARGET" {
  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.10"
}

@test "use custom MACOSX_DEPLOYMENT_TARGET if defined" {
  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'

  MACOSX_DEPLOYMENT_TARGET="10.4" TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.4"
}
