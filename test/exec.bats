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

create_shell_versions() {
  local version
  for version in global local other; do
    mkdir -p "${SHENV_ROOT}/versions/${version}/bin"
    ln -s "$BASH" "${SHENV_ROOT}/versions/${version}/bin/bash"
    SHENV_VERSION="$version" create_executable version-marker <<SH
#!/bin/sh
echo "$version"
SH
  done

  mkdir -p "${SHENV_TEST_DIR}/project/subdir" "${SHENV_TEST_DIR}/other-project"
  cd "$SHENV_TEST_DIR"
  shenv global global
  (cd project && shenv local local)
  (cd other-project && shenv local other)
  shenv rehash
}

@test "a shell launched from the global version follows local versions" {
  # Start outside either project with the global shell selected.
  create_shell_versions

  run bash --noprofile --norc -ec '
    version-marker
    cd project/subdir
    shenv version-name
    version-marker
  '

  # Both selection and commands must follow the parent project version file.
  assert_success
  assert_output <<OUT
global
local
local
OUT
}

@test "a shell launched from a local version follows directory changes" {
  # Start inside a project, then visit another project and leave both.
  create_shell_versions
  cd project

  run bash --noprofile --norc -ec '
    version-marker
    cd ../other-project
    shenv version-name
    version-marker
    cd ..
    shenv version-name
    version-marker
  '

  # The starting project must not pin the version or its search directory.
  assert_success
  assert_output <<OUT
local
other
other
global
global
OUT
}

@test "an empty SHENV_VERSION does not pin a child shell" {
  create_shell_versions

  SHENV_VERSION= run bash --noprofile --norc -ec '
    cd project
    shenv version-name
    version-marker
  '

  # An empty override must allow the project version to take effect.
  assert_success
  assert_output <<OUT
local
local
OUT
}

@test "an explicit shell version still overrides local versions in a child shell" {
  create_shell_versions
  eval "$(shenv init - --no-rehash bash)"
  shenv shell global

  run bash --noprofile --norc -ec '
    cd project
    shenv version-name
    version-marker
  '

  # Only an explicit shell override should keep the global version selected.
  assert_success
  assert_output <<OUT
global
global
OUT
}

@test "an explicit SHENV_DIR is preserved in a child shell" {
  create_shell_versions

  SHENV_DIR="${SHENV_TEST_DIR}/project" run bash --noprofile --norc -ec '
    cd other-project
    shenv version-name
    version-marker
  '

  # An explicit search directory must continue to override the current directory.
  assert_success
  assert_output <<OUT
local
local
OUT
}

@test "exec preserves PATH for a system shell" {
  # A system shell must retain shims and other version managers in PATH.
  mkdir -p "$SHENV_TEST_DIR"
  cd "$SHENV_TEST_DIR"

  run shenv-exec bash --noprofile --norc -c 'printf "%s\n" "$PATH"'

  assert_success "$PATH"
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

@test "runs scripts with a shimmed shell in the shebang" {
  export SHENV_VERSION="3.4"
  # Resolve both the script and its interpreter through shims.
  create_executable "fab" <<SH
#!/usr/bin/env bash
echo hello fab
SH
  ln -s "$BASH" "${SHENV_ROOT}/versions/3.4/bin/bash"

  shenv-rehash

  run bash --noprofile --norc -c fab

  assert_success "hello fab"
}
