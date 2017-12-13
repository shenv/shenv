#!/usr/bin/env bats

load test_helper

setup() {
  export SHENV_ROOT="${TMP}/shenv"
  export HOOK_PATH="${TMP}/i has hooks"
  mkdir -p "$HOOK_PATH"
}

@test "shenv-install hooks" {
  cat > "${HOOK_PATH}/install.bash" <<OUT
before_install 'echo before: \$PREFIX'
after_install 'echo after: \$STATUS'
OUT
  stub shenv-hooks "install : echo '$HOOK_PATH'/install.bash"
  stub shenv-rehash "echo rehashed"

  definition="${TMP}/3.6.2"
  cat > "$definition" <<<"echo shell-build"
  run shenv-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${SHENV_ROOT}/versions/3.6.2
shell-build
after: 0
rehashed
OUT
}

@test "shenv-uninstall hooks" {
  cat > "${HOOK_PATH}/uninstall.bash" <<OUT
before_uninstall 'echo before: \$PREFIX'
after_uninstall 'echo after.'
rm() {
  echo "rm \$@"
  command rm "\$@"
}
OUT
  stub shenv-hooks "uninstall : echo '$HOOK_PATH'/uninstall.bash"
  stub shenv-rehash "echo rehashed"

  mkdir -p "${SHENV_ROOT}/versions/3.6.2"
  run shenv-uninstall -f 3.6.2

  assert_success
  assert_output <<-OUT
before: ${SHENV_ROOT}/versions/3.6.2
rm -rf ${SHENV_ROOT}/versions/3.6.2
rehashed
after.
OUT

  refute [ -d "${SHENV_ROOT}/versions/3.6.2" ]
}
