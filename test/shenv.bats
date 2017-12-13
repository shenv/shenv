#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run shenv
  assert_failure
  assert_line 0 "$(shenv---version)"
}

@test "invalid command" {
  run shenv does-not-exist
  assert_failure
  assert_output "shenv: no such command \`does-not-exist'"
}

@test "default SHENV_ROOT" {
  SHENV_ROOT="" HOME=/home/mislav run shenv root
  assert_success
  assert_output "/home/mislav/.shenv"
}

@test "inherited SHENV_ROOT" {
  SHENV_ROOT=/opt/shenv run shenv root
  assert_success
  assert_output "/opt/shenv"
}

@test "default SHENV_DIR" {
  run shenv echo SHENV_DIR
  assert_output "$(pwd)"
}

@test "inherited SHENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  SHENV_DIR="$dir" run shenv echo SHENV_DIR
  assert_output "$dir"
}

@test "invalid SHENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  SHENV_DIR="$dir" run shenv echo SHENV_DIR
  assert_failure
  assert_output "shenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run shenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$SHENV_ROOT"/plugins/shell-build/bin
  mkdir -p "$SHENV_ROOT"/plugins/shenv-each/bin
  run shenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${SHENV_ROOT}/plugins/shell-build/bin"
  assert_line 2 "${SHENV_ROOT}/plugins/shenv-each/bin"
}

@test "SHENV_HOOK_PATH preserves value from environment" {
  SHENV_HOOK_PATH=/my/hook/path:/other/hooks run shenv echo -F: "SHENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${SHENV_ROOT}/shenv.d"
}

@test "SHENV_HOOK_PATH includes shenv built-in plugins" {
  unset SHENV_HOOK_PATH
  run shenv echo "SHENV_HOOK_PATH"
  assert_success "${SHENV_ROOT}/shenv.d:${BATS_TEST_DIRNAME%/*}/shenv.d:/usr/local/etc/shenv.d:/etc/shenv.d:/usr/lib/shenv/hooks"
}
