#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${SHENV_ROOT}/shims" ]
  assert [ ! -d "${SHENV_ROOT}/versions" ]
  run shenv-init -
  assert_success
  assert [ -d "${SHENV_ROOT}/shims" ]
  assert [ -d "${SHENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run shenv-init -
  assert_success
  assert_line "command shenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run shenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/shenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run shenv-init -
  assert_success
  assert_line "export SHENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(shenv-init -)"
echo \$SHENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run shenv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/shenv.fish'"
}

@test "fish instructions" {
  run shenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and source (shenv init -|psub)'
}

@test "option to skip rehash" {
  run shenv-init - --no-rehash
  assert_success
  refute_line "shenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run shenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${SHENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run shenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${SHENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${SHENV_ROOT}/shims:$PATH"
  run shenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${SHENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${SHENV_ROOT}/shims:$PATH"
  run shenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${SHENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run shenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run shenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run shenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
