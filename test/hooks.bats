#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run shenv-hooks
  assert_failure "Usage: shenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${SHENV_TEST_DIR}/shenv.d"
  path2="${SHENV_TEST_DIR}/etc/shenv_hooks"
  SHENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  SHENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  SHENV_HOOK_PATH="$path1:$path2" run shenv-hooks exec
  assert_success
  assert_output <<OUT
${SHENV_TEST_DIR}/shenv.d/exec/ahoy.bash
${SHENV_TEST_DIR}/shenv.d/exec/hello.bash
${SHENV_TEST_DIR}/etc/shenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${SHENV_TEST_DIR}/my hooks/shenv.d"
  path2="${SHENV_TEST_DIR}/etc/shenv hooks"
  SHENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  SHENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  SHENV_HOOK_PATH="$path1:$path2" run shenv-hooks exec
  assert_success
  assert_output <<OUT
${SHENV_TEST_DIR}/my hooks/shenv.d/exec/hello.bash
${SHENV_TEST_DIR}/etc/shenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  SHENV_HOOK_PATH="${SHENV_TEST_DIR}/shenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  SHENV_HOOK_PATH="${HOME}/../shenv.d" run shenv-hooks exec
  assert_success "${SHENV_TEST_DIR}/shenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${SHENV_TEST_DIR}/shenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  SHENV_HOOK_PATH="$path" run shenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${SHENV_TEST_DIR}/shenv.d/exec/bright.sh
OUT
}
