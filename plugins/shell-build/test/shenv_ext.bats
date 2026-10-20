#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$INSTALL_ROOT"
  stub md5 false
  stub curl false
}

@test "default MACOSX_DEPLOYMENT_TARGET" {
  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.10"
}

@test "use custom MACOSX_DEPLOYMENT_TARGET if defined" {
  # pyenv/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'

  MACOSX_DEPLOYMENT_TARGET="10.4" TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.4"
}
