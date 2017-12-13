#!/usr/bin/env bats

load test_helper
NUM_DEFINITIONS="$(find "$BATS_TEST_DIRNAME"/../share/shell-build -maxdepth 1 -type f | wc -l)"

@test "list built-in definitions" {
  run shell-build --definitions
  assert_success
  assert_output_contains "2.7.8"
  assert_output_contains "jython-2.5.3"
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
  touch "${SHELL_BUILD_ROOT}/share/shell-build/2.7.8-test"
  run shell-build --definitions
  assert_success "2.7.8-test"
}

@test "one path via SHELL_BUILD_DEFINITIONS" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions"
  mkdir -p "$SHELL_BUILD_DEFINITIONS"
  touch "${SHELL_BUILD_DEFINITIONS}/2.7.8-test"
  run shell-build --definitions
  assert_success
  assert_output_contains "2.7.8-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 1))" ]
}

@test "multiple paths via SHELL_BUILD_DEFINITIONS" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  touch "${TMP}/definitions/2.7.8-test"
  mkdir -p "${TMP}/other"
  touch "${TMP}/other/3.4.2-test"
  run shell-build --definitions
  assert_success
  assert_output_contains "2.7.8-test"
  assert_output_contains "3.4.2-test"
  assert [ "${#lines[*]}" -eq "$((NUM_DEFINITIONS + 2))" ]
}

@test "installing definition from SHELL_BUILD_DEFINITIONS by priority" {
  export SHELL_BUILD_DEFINITIONS="${TMP}/definitions:${TMP}/other"
  mkdir -p "${TMP}/definitions"
  echo true > "${TMP}/definitions/2.7.8-test"
  mkdir -p "${TMP}/other"
  echo false > "${TMP}/other/2.7.8-test"
  run bin/shell-build "2.7.8-test" "${TMP}/install"
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
  expected="2.7-dev
2.7
2.7.1
2.7.2
2.7.3
3.4.0
3.4-dev
3.4.1
3.4.2
jython-dev
jython-2.5.0
jython-2.5-dev
jython-2.5.1
jython-2.5.2
jython-2.5.3
jython-2.5.4-rc1
jython-2.7-beta1
jython-2.7-beta2
jython-2.7-beta3"
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
  touch "${SHELL_BUILD_DEFINITIONS}/2.7.8"
  touch "${SHELL_BUILD_DEFINITIONS}/3.4.2"

  run shell-build --definitions
  assert_success
  assert_output <<OUT
2.7.8
3.4.2
OUT
}
