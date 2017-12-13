#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "detects global 'version' file" {
  create_file "${SHENV_ROOT}/version"
  run shenv-version-file
  assert_success "${SHENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${SHENV_ROOT}/version" ]
  assert [ ! -e ".shell-version" ]
  run shenv-version-file
  assert_success "${SHENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".shell-version"
  run shenv-version-file
  assert_success "${SHENV_TEST_DIR}/.shell-version"
}

@test "in parent directory" {
  create_file ".shell-version"
  mkdir -p project
  cd project
  run shenv-version-file
  assert_success "${SHENV_TEST_DIR}/.shell-version"
}

@test "topmost file has precedence" {
  create_file ".shell-version"
  create_file "project/.shell-version"
  cd project
  run shenv-version-file
  assert_success "${SHENV_TEST_DIR}/project/.shell-version"
}

@test "SHENV_DIR has precedence over PWD" {
  create_file "widget/.shell-version"
  create_file "project/.shell-version"
  cd project
  SHENV_DIR="${SHENV_TEST_DIR}/widget" run shenv-version-file
  assert_success "${SHENV_TEST_DIR}/widget/.shell-version"
}

@test "PWD is searched if SHENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.shell-version"
  cd project
  SHENV_DIR="${SHENV_TEST_DIR}/widget/blank" run shenv-version-file
  assert_success "${SHENV_TEST_DIR}/project/.shell-version"
}

@test "finds version file in target directory" {
  create_file "project/.shell-version"
  run shenv-version-file "${PWD}/project"
  assert_success "${SHENV_TEST_DIR}/project/.shell-version"
}

@test "fails when no version file in target directory" {
  run shenv-version-file "$PWD"
  assert_failure ""
}
