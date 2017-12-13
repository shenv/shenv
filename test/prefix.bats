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
  touch "${SHENV_TEST_DIR}/bin/shell"
  chmod +x "${SHENV_TEST_DIR}/bin/shell"
  SHENV_VERSION="system" run shenv-prefix
  assert_success "$SHENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/shenv-which" <<OUT
#!/bin/sh
echo /bin/shell
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/shenv-which"
  SHENV_VERSION="system" run shenv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/shenv-which"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/shenv-which" <<OUT
#!/bin/sh
echo /bin/shell
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/shenv-which"
  SHENV_VERSION="system" run shenv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/shenv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without shell)" run shenv-prefix system
  assert_failure "shenv: system version not found in PATH"
}
