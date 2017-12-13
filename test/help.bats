#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run shenv-help
  assert_success
  assert_line "Usage: shenv <command> [<args>]"
  assert_line "Some useful shenv commands are:"
}

@test "invalid command" {
  run shenv-help hello
  assert_failure "shenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  cat > "${SHENV_TEST_DIR}/bin/shenv-hello" <<SH
#!shebang
# Usage: shenv hello <world>
# Summary: Says "hello" to you, from shenv
# This command is useful for saying hello.
echo hello
SH

  run shenv-help hello
  assert_success
  assert_output <<SH
Usage: shenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  cat > "${SHENV_TEST_DIR}/bin/shenv-hello" <<SH
#!shebang
# Usage: shenv hello <world>
# Summary: Says "hello" to you, from shenv
echo hello
SH

  run shenv-help hello
  assert_success
  assert_output <<SH
Usage: shenv hello <world>

Says "hello" to you, from shenv
SH
}

@test "extracts only usage" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  cat > "${SHENV_TEST_DIR}/bin/shenv-hello" <<SH
#!shebang
# Usage: shenv hello <world>
# Summary: Says "hello" to you, from shenv
# This extended help won't be shown.
echo hello
SH

  run shenv-help --usage hello
  assert_success "Usage: shenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  cat > "${SHENV_TEST_DIR}/bin/shenv-hello" <<SH
#!shebang
# Usage: shenv hello <world>
#        shenv hi [everybody]
#        shenv hola --translate
# Summary: Says "hello" to you, from shenv
# Help text.
echo hello
SH

  run shenv-help hello
  assert_success
  assert_output <<SH
Usage: shenv hello <world>
       shenv hi [everybody]
       shenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${SHENV_TEST_DIR}/bin"
  cat > "${SHENV_TEST_DIR}/bin/shenv-hello" <<SH
#!shebang
# Usage: shenv hello <world>
# Summary: Says "hello" to you, from shenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run shenv-help hello
  assert_success
  assert_output <<SH
Usage: shenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
