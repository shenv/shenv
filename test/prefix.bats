#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${SHENV_TEST_DIR}/myproject"
  cd "${SHENV_TEST_DIR}/myproject"
  echo "1.2.3" > .shell-version
  mkdir -p "${SHENV_ROOT}/versions/1.2.3"
  run shenv-prefix
  assert_success "${SHENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  SHENV_VERSION="1.2.3" run shenv-prefix
  assert_failure "shenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${SHENV_TEST_DIR}/bin"

  # System shells have their own names, without a generic `shell` executable.
  for shell_name in bash zsh fish; do
    touch "${SHENV_TEST_DIR}/bin/${shell_name}"
    chmod +x "${SHENV_TEST_DIR}/bin/${shell_name}"

    SHELL="/bin/${shell_name}" SHENV_VERSION="system" run shenv-prefix

    assert_success "$SHENV_TEST_DIR"
  done
}

@test "prefix for system with empty SHELL" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  touch "${SHENV_TEST_DIR}/bin/sh"
  chmod +x "${SHENV_TEST_DIR}/bin/sh"

  SHELL= run shenv-prefix system

  assert_success "$SHENV_TEST_DIR"
}

@test "prefix for system ignores shims" {
  mkdir -p "${SHENV_TEST_DIR}/bin" "${SHENV_ROOT}/shims"
  touch "${SHENV_TEST_DIR}/bin/zsh" "${SHENV_ROOT}/shims/zsh"
  chmod +x "${SHENV_TEST_DIR}/bin/zsh" "${SHENV_ROOT}/shims/zsh"

  SHELL="${SHENV_ROOT}/shims/zsh" run shenv-prefix system

  assert_success "$SHENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/shenv-which" <<OUT
#!/bin/sh
echo /bin/sh
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/shenv-which"
  SHENV_VERSION="system" run shenv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/shenv-which"
}

@test "prefix for invalid system" {
  SHELL=/bin/shenv-nonexistent-shell run shenv-prefix system

  assert_failure "shenv: system version not found in PATH"
}
