#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${SHENV_TEST_DIR}/myproject"
  cd "${SHENV_TEST_DIR}/myproject"
  echo "1.2.3" > .shell-version
  SHENV_VERSION="" run shenv-sh-shell
  assert_failure "shenv: no shell-specific version configured"
}

@test "shell version" {
  SHENV_SHELL=bash SHENV_VERSION="1.2.3" run shenv-sh-shell
  assert_success 'echo "$SHENV_VERSION"'
}

@test "shell version (fish)" {
  SHENV_SHELL=fish SHENV_VERSION="1.2.3" run shenv-sh-shell
  assert_success 'echo "$SHENV_VERSION"'
}

@test "shell revert" {
  SHENV_SHELL=bash run shenv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${SHENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  SHENV_SHELL=fish run shenv-sh-shell -
  assert_success
  assert_line 0 'if set -q SHENV_VERSION_OLD'
}

@test "shell unset" {
  SHENV_SHELL=bash run shenv-sh-shell --unset
  assert_success
  assert_output <<OUT
SHENV_VERSION_OLD="\${SHENV_VERSION-}"
unset SHENV_VERSION
OUT
}

@test "shell unset (fish)" {
  SHENV_SHELL=fish run shenv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu SHENV_VERSION_OLD "\$SHENV_VERSION"
set -e SHENV_VERSION
OUT
}

@test "shell change invalid version" {
  run shenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
shenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${SHENV_ROOT}/versions/1.2.3"
  SHENV_SHELL=bash run shenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
SHENV_VERSION_OLD="\${SHENV_VERSION-}"
export SHENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${SHENV_ROOT}/versions/1.2.3"
  SHENV_SHELL=fish run shenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu SHENV_VERSION_OLD "\$SHENV_VERSION"
set -gx SHENV_VERSION "1.2.3"
OUT
}
