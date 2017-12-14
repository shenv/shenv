#!/usr/bin/env bats

load test_helper

@test "installs shell-build into PREFIX" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  cd usr

  assert [ -x bin/shell-build ]
  assert [ -x bin/shenv-install ]
  assert [ -x bin/shenv-uninstall ]

  assert [ -e share/shell-build/bash-4.4 ]
  assert [ -e share/shell-build/fish-2.7.0 ]
}

@test "build definitions don't have the executable bit" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  run $BASH -c 'stat -c %A usr/share/shell-build/*-* | uniq'
  assert_output '-rw-r--r--'
}

@test "overwrites old installation" {
  cd "$TMP"
  mkdir -p bin share/shell-build
  touch bin/shell-build
  touch share/shell-build/bash-4.4

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -x bin/shell-build ]
  run grep "install_package" share/shell-build/bash-4.4
  assert_success
}

@test "unrelated files are untouched" {
  cd "$TMP"
  mkdir -p bin share/bananas
  chmod g-w bin
  touch bin/bananas
  touch share/bananas/docs

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -e bin/bananas ]
  assert [ -e share/bananas/docs ]

  run ls -ld bin
  assert_equal "r-x" "${output:4:3}"
}
