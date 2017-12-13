#!/usr/bin/env bats

load test_helper

@test "not enough arguments for shell-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run shell-build "$definition"
  assert_failure
  assert_output_contains 'Usage: shell-build'
}

@test "extra arguments for shell-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run shell-build "$definition" "${TMP}/install" ""
  assert_failure
  assert_output_contains 'Usage: shell-build'
}
