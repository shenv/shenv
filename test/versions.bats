#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${SHENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
}

stub_system_shell() {
  local stub="${SHENV_TEST_DIR}/bin/shell"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_shell
  assert [ ! -d "${SHENV_ROOT}/versions" ]
  run shenv-versions
  assert_success "* system (set by ${SHENV_ROOT}/version)"
}

@test "not even system shell available" {
  PATH="$(path_without shell)" run shenv-versions
  assert_failure
  assert_output "Warning: no shell detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${SHENV_ROOT}/versions" ]
  run shenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_shell
  create_version "3.3"
  run shenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${SHENV_ROOT}/version)
  3.3
OUT
}

@test "single version bare" {
  create_version "3.3"
  run shenv-versions --bare
  assert_success "3.3"
}

@test "multiple versions" {
  stub_system_shell
  create_version "2.7.6"
  create_version "3.3.3"
  create_version "3.4.0"
  run shenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${SHENV_ROOT}/version)
  2.7.6
  3.3.3
  3.4.0
OUT
}

@test "indicates current version" {
  stub_system_shell
  create_version "3.3.3"
  create_version "3.4.0"
  SHENV_VERSION=3.3.3 run shenv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by SHENV_VERSION environment variable)
  3.4.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "3.3.3"
  create_version "3.4.0"
  SHENV_VERSION=3.3.3 run shenv-versions --bare
  assert_success
  assert_output <<OUT
3.3.3
3.4.0
OUT
}

@test "globally selected version" {
  stub_system_shell
  create_version "3.3.3"
  create_version "3.4.0"
  cat > "${SHENV_ROOT}/version" <<<"3.3.3"
  run shenv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by ${SHENV_ROOT}/version)
  3.4.0
OUT
}

@test "per-project version" {
  stub_system_shell
  create_version "3.3.3"
  create_version "3.4.0"
  cat > ".shell-version" <<<"3.3.3"
  run shenv-versions
  assert_success
  assert_output <<OUT
  system
* 3.3.3 (set by ${SHENV_TEST_DIR}/.shell-version)
  3.4.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "3.3"
  touch "${SHENV_ROOT}/versions/hello"

  run shenv-versions --bare
  assert_success "3.3"
}

@test "lists symlinks under versions" {
  create_version "2.7.8"
  ln -s "2.7.8" "${SHENV_ROOT}/versions/2.7"

  run shenv-versions --bare
  assert_success
  assert_output <<OUT
2.7
2.7.8
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "1.8.7"
  ln -s "1.8.7" "${SHENV_ROOT}/versions/1.8"
  mkdir moo
  ln -s "${PWD}/moo" "${SHENV_ROOT}/versions/1.9"

  run shenv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
1.8.7
1.9
OUT
}
