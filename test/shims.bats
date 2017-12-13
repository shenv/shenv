#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run shenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${SHENV_ROOT}/shims"
  touch "${SHENV_ROOT}/shims/shell"
  touch "${SHENV_ROOT}/shims/irb"
  run shenv-shims
  assert_success
  assert_line "${SHENV_ROOT}/shims/shell"
  assert_line "${SHENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${SHENV_ROOT}/shims"
  touch "${SHENV_ROOT}/shims/shell"
  touch "${SHENV_ROOT}/shims/irb"
  run shenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "shell"
}
