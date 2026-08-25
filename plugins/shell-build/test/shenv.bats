#!/usr/bin/env bats

load test_helper
export SHENV_ROOT="${TMP}/shenv"

setup() {
  stub shenv-hooks 'install : true'
  stub shenv-rehash 'true'
}

stub_shell_build() {
  stub shell-build "--lib : $BATS_TEST_DIRNAME/../bin/shell-build --lib" "$@"
}

@test "install proper" {
  stub_shell_build 'echo shell-build "$@"'

  run shenv-install bash-4.4
  assert_success "shell-build bash-4.4 ${SHENV_ROOT}/versions/bash-4.4"

  unstub shell-build
  unstub shenv-hooks
  unstub shenv-rehash
}

@test "install shenv local version by default" {
  stub_shell_build 'echo shell-build "$1"'
  stub shenv-local 'echo bash-4.4'

  run shenv-install
  assert_success "shell-build bash-4.4"

  unstub shell-build
  unstub shenv-local
}

@test "list available versions" {
  stub_shell_build \
    "--definitions : echo bash-4.3 bash-4.4-rc1 bash-4.4-rc2 bash-4.4 | tr ' ' $'\\n'"

  run shenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  bash-4.3
  bash-4.4-rc1
  bash-4.4-rc2
  bash-4.4
OUT

  unstub shell-build
}

@test "nonexistent version" {
  stub brew false
  stub_shell_build 'echo ERROR >&2 && exit 2' \
    "--definitions : echo bash-4.3 bash-4.4-rc1 bash-4.4-rc2 bash-4.4 | tr ' ' $'\\n'"

  run shenv-install bash-4.4-rc
  assert_failure
  assert_output <<OUT
ERROR

The following versions contain \`bash-4.4-rc' in the name:
  bash-4.4-rc1
  bash-4.4-rc2

See all available versions with \`shenv install --list'.

If the version you need is missing, try upgrading shenv:

  cd ${BATS_TEST_DIRNAME}/../../.. && git pull && cd -
OUT

  unstub shell-build
}

@test "Homebrew upgrade instructions" {
  stub brew "--prefix : echo '${BATS_TEST_DIRNAME%/*}'"
  stub_shell_build 'echo ERROR >&2 && exit 2' \
    "--definitions : true"

  run shenv-install 1.9.3
  assert_failure
  assert_output <<OUT
ERROR

See all available versions with \`shenv install --list'.

If the version you need is missing, try upgrading shenv:

  brew update && brew upgrade shenv
OUT

  unstub brew
  unstub shell-build
}

@test "no build definitions from plugins" {
  assert [ ! -e "${SHENV_ROOT}/plugins" ]
  stub_shell_build 'echo $SHELL_BUILD_DEFINITIONS'

  run shenv-install bash-4.4
  assert_success ""
}

@test "some build definitions from plugins" {
  mkdir -p "${SHENV_ROOT}/plugins/foo/share/shell-build"
  mkdir -p "${SHENV_ROOT}/plugins/bar/share/shell-build"
  stub_shell_build "echo \$SHELL_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run shenv-install bash-4.4
  assert_success
  assert_output <<OUT

${SHENV_ROOT}/plugins/bar/share/shell-build
${SHENV_ROOT}/plugins/foo/share/shell-build
OUT
}

@test "list build definitions from plugins" {
  mkdir -p "${SHENV_ROOT}/plugins/foo/share/shell-build"
  mkdir -p "${SHENV_ROOT}/plugins/bar/share/shell-build"
  stub_shell_build "--definitions : echo \$SHELL_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run shenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  
  ${SHENV_ROOT}/plugins/bar/share/shell-build
  ${SHENV_ROOT}/plugins/foo/share/shell-build
OUT
}

@test "completion results include build definitions from plugins" {
  mkdir -p "${SHENV_ROOT}/plugins/foo/share/shell-build"
  mkdir -p "${SHENV_ROOT}/plugins/bar/share/shell-build"
  stub shell-build "--definitions : echo \$SHELL_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run shenv-install --complete
  assert_success
  assert_output <<OUT
--list
--force
--skip-existing
--keep
--patch
--verbose
--version

${SHENV_ROOT}/plugins/bar/share/shell-build
${SHENV_ROOT}/plugins/foo/share/shell-build
OUT
}

@test "not enough arguments for shenv-install" {
  stub_shell_build
  stub shenv-help 'install : true'

  run shenv-install
  assert_failure
  unstub shenv-help
}

@test "too many arguments for shenv-install" {
  stub_shell_build
  stub shenv-help 'install : true'

  run shenv-install bash-4.3 bash-4.4
  assert_failure
  unstub shenv-help
}

@test "show help for shenv-install" {
  stub_shell_build
  stub shenv-help 'install : true'

  run shenv-install -h
  assert_success
  unstub shenv-help
}

@test "shenv-install has usage help preface" {
  run head "$(command -v shenv-install)"
  assert_output_contains 'Usage: shenv install'
}

@test "not enough arguments shenv-uninstall" {
  stub shenv-help 'uninstall : true'

  run shenv-uninstall
  assert_failure
  unstub shenv-help
}

@test "too many arguments for shenv-uninstall" {
  stub shenv-help 'uninstall : true'

  run shenv-uninstall bash-4.3 bash-4.4
  assert_failure
  unstub shenv-help
}

@test "show help for shenv-uninstall" {
  stub shenv-help 'uninstall : true'

  run shenv-uninstall -h
  assert_success
  unstub shenv-help
}

@test "shenv-uninstall has usage help preface" {
  run head "$(command -v shenv-uninstall)"
  assert_output_contains 'Usage: shenv uninstall'
}
