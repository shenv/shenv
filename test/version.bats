#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${SHENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${SHENV_ROOT}/versions" ]
  run shenv-version
  assert_success "system (set by ${SHENV_ROOT}/version)"
}

@test "set by SHENV_VERSION" {
  create_version "3.3.3"
  SHENV_VERSION=3.3.3 run shenv-version
  assert_success "3.3.3 (set by SHENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "3.3.3"
  cat > ".shell-version" <<<"3.3.3"
  run shenv-version
  assert_success "3.3.3 (set by ${PWD}/.shell-version)"
}

@test "set by global file" {
  create_version "3.3.3"
  cat > "${SHENV_ROOT}/version" <<<"3.3.3"
  run shenv-version
  assert_success "3.3.3 (set by ${SHENV_ROOT}/version)"
}

@test "set by SHENV_VERSION, one missing" {
  create_version "3.3.3"
  SHENV_VERSION=3.3.3:1.2 run shenv-version
  assert_failure
  assert_output <<OUT
shenv: version \`1.2' is not installed (set by SHENV_VERSION environment variable)
3.3.3 (set by SHENV_VERSION environment variable)
OUT
}

@test "set by SHENV_VERSION, two missing" {
  create_version "3.3.3"
  SHENV_VERSION=3.4.2:3.3.3:1.2 run shenv-version
  assert_failure
  assert_output <<OUT
shenv: version \`3.4.2' is not installed (set by SHENV_VERSION environment variable)
shenv: version \`1.2' is not installed (set by SHENV_VERSION environment variable)
3.3.3 (set by SHENV_VERSION environment variable)
OUT
}

shenv-version-without-stderr() {
  shenv-version 2>/dev/null
}

@test "set by SHENV_VERSION, one missing (stderr filtered)" {
  create_version "3.3.3"
  SHENV_VERSION=3.4.2:3.3.3 run shenv-version-without-stderr
  assert_failure
  assert_output <<OUT
3.3.3 (set by SHENV_VERSION environment variable)
OUT
}
