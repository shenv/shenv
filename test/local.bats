#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${SHENV_TEST_DIR}/myproject"
  cd "${SHENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.shell-version" ]
  run shenv-local
  assert_failure "shenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .shell-version
  run shenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .shell-version
  mkdir -p "subdir" && cd "subdir"
  run shenv-local
  assert_success "1.2.3"
}

@test "ignores SHENV_DIR" {
  echo "1.2.3" > .shell-version
  mkdir -p "$HOME"
  echo "3.4-home" > "${HOME}/.shell-version"
  SHENV_DIR="$HOME" run shenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${SHENV_ROOT}/versions/1.2.3"
  run shenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .shell-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .shell-version
  mkdir -p "${SHENV_ROOT}/versions/1.2.3"
  run shenv-local
  assert_success "1.0-pre"
  run shenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .shell-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .shell-version
  run shenv-local --unset
  assert_success ""
  assert [ ! -e .shell-version ]
}
