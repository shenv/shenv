#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run shenv-version-file-write
  assert_failure "Usage: shenv version-file-write <file> <version>"
  run shenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".shell-version" ]
  run shenv-version-file-write ".shell-version" "2.7.6"
  assert_failure "shenv: version \`2.7.6' not installed"
  assert [ ! -e ".shell-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${SHENV_ROOT}/versions/2.7.6"
  assert [ ! -e "my-version" ]
  run shenv-version-file-write "${PWD}/my-version" "2.7.6"
  assert_success ""
  assert [ "$(cat my-version)" = "2.7.6" ]
}
