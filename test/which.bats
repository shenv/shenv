#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${SHENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "2.7" "shell"
  create_executable "3.4" "py.test"

  SHENV_VERSION=2.7 run shenv-which shell
  assert_success "${SHENV_ROOT}/versions/2.7/bin/shell"

  SHENV_VERSION=3.4 run shenv-which py.test
  assert_success "${SHENV_ROOT}/versions/3.4/bin/py.test"

  SHENV_VERSION=3.4:2.7 run shenv-which py.test
  assert_success "${SHENV_ROOT}/versions/3.4/bin/py.test"
}

@test "searches PATH for system version" {
  create_executable "${SHENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${SHENV_ROOT}/shims" "kill-all-humans"

  SHENV_VERSION=system run shenv-which kill-all-humans
  assert_success "${SHENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${SHENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${SHENV_ROOT}/shims" "kill-all-humans"

  PATH="${SHENV_ROOT}/shims:$PATH" SHENV_VERSION=system run shenv-which kill-all-humans
  assert_success "${SHENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${SHENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${SHENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${SHENV_ROOT}/shims" SHENV_VERSION=system run shenv-which kill-all-humans
  assert_success "${SHENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${SHENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${SHENV_ROOT}/shims" "kill-all-humans"

  PATH="${SHENV_ROOT}/shims:${SHENV_ROOT}/shims:/tmp/non-existent:$PATH:${SHENV_ROOT}/shims" \
    SHENV_VERSION=system run shenv-which kill-all-humans
  assert_success "${SHENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  export PATH="$(path_without "kill-all-humans")"
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  SHENV_VERSION=system run shenv-which kill-all-humans
  assert_failure "shenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "3.4" "py.test"
  SHENV_VERSION=3.3 run shenv-which py.test
  assert_failure "shenv: version \`3.3' is not installed (set by SHENV_VERSION environment variable)"
}

@test "versions not installed" {
  create_executable "3.4" "py.test"
  SHENV_VERSION=2.7:3.3 run shenv-which py.test
  assert_failure <<OUT
shenv: version \`2.7' is not installed (set by SHENV_VERSION environment variable)
shenv: version \`3.3' is not installed (set by SHENV_VERSION environment variable)
OUT
}

@test "no executable found" {
  create_executable "2.7" "py.test"
  SHENV_VERSION=2.7 run shenv-which fab
  assert_failure "shenv: fab: command not found"
}

@test "no executable found for system version" {
  export PATH="$(path_without "py.test")"
  SHENV_VERSION=system run shenv-which py.test
  assert_failure "shenv: py.test: command not found"
}

@test "executable found in other versions" {
  create_executable "2.7" "shell"
  create_executable "3.3" "py.test"
  create_executable "3.4" "py.test"

  SHENV_VERSION=2.7 run shenv-which py.test
  assert_failure
  assert_output <<OUT
shenv: py.test: command not found

The \`py.test' command exists in these shell versions:
  3.3
  3.4
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' SHENV_VERSION=system run shenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from shenv-version-name" {
  mkdir -p "$SHENV_ROOT"
  cat > "${SHENV_ROOT}/version" <<<"3.4"
  create_executable "3.4" "shell"

  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"

  SHENV_VERSION= run shenv-which shell
  assert_success "${SHENV_ROOT}/versions/3.4/bin/shell"
}
