#!/usr/bin/env bats

load test_helper

@test "default" {
  run shenv-global
  assert_success
  assert_output "system"
}

@test "read SHENV_ROOT/version" {
  mkdir -p "$SHENV_ROOT"
  echo "1.2.3" > "$SHENV_ROOT/version"
  run shenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set SHENV_ROOT/version" {
  mkdir -p "$SHENV_ROOT/versions/1.2.3"
  run shenv-global "1.2.3"
  assert_success
  run shenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid SHENV_ROOT/version" {
  mkdir -p "$SHENV_ROOT"
  run shenv-global "1.2.3"
  assert_failure "shenv: version \`1.2.3' not installed"
}
