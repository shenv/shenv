#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${SHENV_ROOT}/version" ]
  run shenv-version-origin
  assert_success "${SHENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$SHENV_ROOT"
  touch "${SHENV_ROOT}/version"
  run shenv-version-origin
  assert_success "${SHENV_ROOT}/version"
}

@test "detects SHENV_VERSION" {
  SHENV_VERSION=1 run shenv-version-origin
  assert_success "SHENV_VERSION environment variable"
}

@test "detects local file" {
  touch .shell-version
  run shenv-version-origin
  assert_success "${PWD}/.shell-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"SHENV_VERSION_ORIGIN=plugin"

  SHENV_VERSION=1 run shenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export SHENV_VERSION=system
  IFS=$' \t\n' run shenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit SHENV_VERSION_ORIGIN from environment" {
  SHENV_VERSION_ORIGIN=ignored run shenv-version-origin
  assert_success "${SHENV_ROOT}/version"
}
