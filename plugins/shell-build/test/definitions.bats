#!/usr/bin/env bats

load test_helper
NUM_DEFINITIONS="$(find "$BATS_TEST_DIRNAME"/../share/shell-build -maxdepth 1 -type f | wc -l)"

@test "list built-in definitions" {
  run shell-build --definitions
  assert_success
  assert_output_contains "bash-4.4"
  assert_output_contains "fish-2.7.0"
  assert [ "${#lines[*]}" -eq "$NUM_DEFINITIONS" ]
}

@test "custom SHELL_BUILD_ROOT: nonexistent" {
  export SHELL_BUILD_ROOT="$TMP"
  refute [ -e "${SHELL_BUILD_ROOT}/share/shell-build" ]
  run shell-build --definitions
  assert_success ""
}

@test "custom SHELL_BUILD_ROOT: single definition" {
  export SHELL_BUILD_ROOT="$TMP"
  mkdir -p "${SHELL_BUILD_ROOT}/share/shell-build"
  touch "${SHELL_BUILD_ROOT}/share/shell-build/bash-4.4-test"
  run shell-build --definitions
  assert_success "bash-4.4-test"
}

@test "one path via SHELL_BUILD_DEFINITIONS" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions"
  mkdir -p "$SHELL_BUILD_DEFINITIONS"
  touch "${SHELL_BUILD_DEFINITIONS}/bash-4.4-test"
  run shell-build --definitions
  assert_success
  assert_output_contains "bash-4.4-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 1))" ]
}

@test "multiple paths via SHELL_BUILD_DEFINITIONS" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  touch "${TMP}/definitions/bash-4.4-test"
  mkdir -p "${TMP}/other"
  touch "${TMP}/other/fish-2.7.0-test"
  run shell-build --definitions
  assert_success
  assert_output_contains "bash-4.4-test"
  assert_output_contains "fish-2.7.0-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 2))" ]
}

@test "installing definition from SHELL_BUILD_DEFINITIONS by priority" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  echo true > "${TMP}/definitions/bash-4.4-test"
  mkdir -p "${TMP}/other"
  echo false > "${TMP}/other/bash-4.4-test"
  run bin/shell-build "bash-4.4-test" "${TMP}/install"
  assert_success ""
}

@test "installing nonexistent definition" {
  run shell-build "nonexistent" "${TMP}/install"
  assert [ "$status" -eq 2 ]
  assert_output "shell-build: definition not found: nonexistent"
}

@test "sorting shell versions" {
  export SHELL_BUILD_ROOT="$TMP"
  mkdir -p "${SHELL_BUILD_ROOT}/share/shell-build"
  expected="bash-2.01
bash-2.04
bash-2.05
bash-3.0
bash-3.0.16
bash-3.1
bash-3.2
bash-3.2.48
bash-4.0
bash-4.1
bash-4.2
bash-4.2.53
bash-4.3
bash-4.3.30
bash-4.4
bash-4.4.12"
  for ver in "$expected"; do
    touch "${SHELL_BUILD_ROOT}/share/shell-build/$ver"
  done
  run shell-build --definitions
  assert_success "$expected"
}

@test "removing duplicate shell versions" {
  export SHELL_BUILD_ROOT="$TMP"
  export SHELL_BUILD_DEFINITIONS="${SHELL_BUILD_ROOT}/share/shell-build"
  mkdir -p "$SHELL_BUILD_DEFINITIONS"
  touch "${SHELL_BUILD_DEFINITIONS}/bash-4.4"
  touch "${SHELL_BUILD_DEFINITIONS}/fish-2.7.0"

  run shell-build --definitions
  assert_success
  assert_output <<OUT
bash-4.4
fish-2.7.0
OUT
}
