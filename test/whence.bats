#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${SHENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "2.7" "shell"
  create_executable "2.7" "fab"
  create_executable "3.4" "shell"
  create_executable "3.4" "py.test"

  run shenv-whence shell
  assert_success
  assert_output <<OUT
2.7
3.4
OUT

  run shenv-whence fab
  assert_success "2.7"

  run shenv-whence py.test
  assert_success "3.4"
}
