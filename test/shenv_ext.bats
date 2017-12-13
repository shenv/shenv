#!/usr/bin/env bats

load test_helper

@test "prefixes" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  touch "${SHENV_TEST_DIR}/bin/shell"
  chmod +x "${SHENV_TEST_DIR}/bin/shell"
  mkdir -p "${SHENV_ROOT}/versions/2.7.10"
  SHENV_VERSION="system:2.7.10" run shenv-prefix
  assert_success "${SHENV_TEST_DIR}:${SHENV_ROOT}/versions/2.7.10"
  SHENV_VERSION="2.7.10:system" run shenv-prefix
  assert_success "${SHENV_ROOT}/versions/2.7.10:${SHENV_TEST_DIR}"
}

@test "should use dirname of file argument as SHENV_DIR" {
  mkdir -p "${SHENV_TEST_DIR}/dir1"
  touch "${SHENV_TEST_DIR}/dir1/file.py"
  SHENV_FILE_ARG="${SHENV_TEST_DIR}/dir1/file.py" run shenv echo SHENV_DIR
  assert_output "${SHENV_TEST_DIR}/dir1"
}

@test "should follow symlink of file argument (#379, #404)" {
  mkdir -p "${SHENV_TEST_DIR}/dir1"
  mkdir -p "${SHENV_TEST_DIR}/dir2"
  touch "${SHENV_TEST_DIR}/dir1/file.py"
  ln -s "${SHENV_TEST_DIR}/dir1/file.py" "${SHENV_TEST_DIR}/dir2/symlink.py"
  SHENV_FILE_ARG="${SHENV_TEST_DIR}/dir2/symlink.py" run shenv echo SHENV_DIR
  assert_output "${SHENV_TEST_DIR}/dir1"
}
