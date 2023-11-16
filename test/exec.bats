#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${SHENV_ROOT}/versions/${SHENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export SHENV_VERSION="3.4"
  run shenv-exec shell -V
  assert_failure "shenv: version \`3.4' is not installed (set by SHENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"
  echo 2.7 > .shell-version
  run shenv-exec rspec
  assert_failure "shenv: version \`2.7' is not installed (set by $PWD/.shell-version)"
}

@test "completes with names of executables" {
  export SHENV_VERSION="3.4"
  create_executable "fab" "#!/bin/sh"
  create_executable "shell" "#!/bin/sh"

  shenv-rehash
  run shenv-completions exec
  assert_success
  assert_output <<OUT
--help
fab
shell
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export SHENV_VERSION=system
  IFS=$' \t\n' run shenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export SHENV_VERSION="3.4"
  create_executable "shell" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run shenv-exec shell -w "/path to/shell script.rb" -- extra args
  assert_success
  assert_output <<OUT
${SHENV_ROOT}/versions/3.4/bin/shell
  -w
  /path to/shell script.rb
  --
  extra
  args
OUT
}
