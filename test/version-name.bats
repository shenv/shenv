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
  run shenv-version-name
  assert_success "system"
}

@test "system version is not checked for existence" {
  SHENV_VERSION=system run shenv-version-name
  assert_success "system"
}

@test "SHENV_VERSION can be overridden by hook" {
  create_version "2.7.11"
  create_version "3.5.1"
  create_hook version-name test.bash <<<"SHENV_VERSION=3.5.1"

  SHENV_VERSION=2.7.11 run shenv-version-name
  assert_success "3.5.1"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export SHENV_VERSION=system
  IFS=$' \t\n' run shenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "SHENV_VERSION has precedence over local" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > ".shell-version" <<<"2.7.11"
  run shenv-version-name
  assert_success "2.7.11"

  SHENV_VERSION=3.5.1 run shenv-version-name
  assert_success "3.5.1"
}

@test "local file has precedence over global" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > "${SHENV_ROOT}/version" <<<"2.7.11"
  run shenv-version-name
  assert_success "2.7.11"

  cat > ".shell-version" <<<"3.5.1"
  run shenv-version-name
  assert_success "3.5.1"
}

@test "missing version" {
  SHENV_VERSION=1.2 run shenv-version-name
  assert_failure "shenv: version \`1.2' is not installed (set by SHENV_VERSION environment variable)"
}

@test "one missing version (second missing)" {
  create_version "3.5.1"
  SHENV_VERSION="3.5.1:1.2" run shenv-version-name
  assert_failure
  assert_output <<OUT
shenv: version \`1.2' is not installed (set by SHENV_VERSION environment variable)
3.5.1
OUT
}

@test "one missing version (first missing)" {
  create_version "3.5.1"
  SHENV_VERSION="1.2:3.5.1" run shenv-version-name
  assert_failure
  assert_output <<OUT
shenv: version \`1.2' is not installed (set by SHENV_VERSION environment variable)
3.5.1
OUT
}

shenv-version-name-without-stderr() {
  shenv-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.5.1"
  SHENV_VERSION="1.2:3.5.1" run shenv-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.5.1
OUT
}

@test "version with prefix in name" {
  create_version "2.7.11"
  cat > ".shell-version" <<<"shell-2.7.11"
  run shenv-version-name
  assert_success
  assert_output "2.7.11"
}
