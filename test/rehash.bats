#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${SHENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${SHENV_ROOT}/shims" ]
  run shenv-rehash
  assert_success ""
  assert [ -d "${SHENV_ROOT}/shims" ]
  rmdir "${SHENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${SHENV_ROOT}/shims"
  chmod -w "${SHENV_ROOT}/shims"
  run shenv-rehash
  assert_failure "shenv: cannot rehash: ${SHENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${SHENV_ROOT}/shims"
  touch "${SHENV_ROOT}/shims/.shenv-shim"
  run shenv-rehash
  assert_failure "shenv: cannot rehash: ${SHENV_ROOT}/shims/.shenv-shim exists"
}

@test "creates shims" {
  create_executable "2.7" "shell"
  create_executable "2.7" "fab"
  create_executable "3.4" "shell"
  create_executable "3.4" "py.test"

  assert [ ! -e "${SHENV_ROOT}/shims/fab" ]
  assert [ ! -e "${SHENV_ROOT}/shims/shell" ]
  assert [ ! -e "${SHENV_ROOT}/shims/py.test" ]

  run shenv-rehash
  assert_success ""

  run ls "${SHENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
fab
py.test
shell
OUT
}

@test "removes stale shims" {
  mkdir -p "${SHENV_ROOT}/shims"
  touch "${SHENV_ROOT}/shims/oldshim1"
  chmod +x "${SHENV_ROOT}/shims/oldshim1"

  create_executable "3.4" "fab"
  create_executable "3.4" "shell"

  run shenv-rehash
  assert_success ""

  assert [ ! -e "${SHENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "shell"
  create_executable "dirname2 preview1" "py.test"

  assert [ ! -e "${SHENV_ROOT}/shims/shell" ]
  assert [ ! -e "${SHENV_ROOT}/shims/py.test" ]

  run shenv-rehash
  assert_success ""

  run ls "${SHENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
py.test
shell
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run shenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "3.4" "shell"
  SHENV_SHELL=bash run shenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${SHENV_ROOT}/shims/shell" ]
}

@test "sh-rehash in fish" {
  create_executable "3.4" "shell"
  SHENV_SHELL=fish run shenv-sh-rehash
  assert_success ""
  assert [ -x "${SHENV_ROOT}/shims/shell" ]
}
