#!/usr/bin/env bats

load test_helper

bats_bin="${BATS_TEST_DIRNAME}/../bin/shell-build"
static_version="$(grep VERSION "$bats_bin" | head -1 | cut -d'"' -f 2)"

@test "shell-build static version" {
  stub git 'echo "ASPLODE" >&2; exit 1'
  run shell-build --version
  assert_success "shell-build ${static_version}"
  unstub git
}

@test "shell-build git version" {
  stub git \
    'remote -v : echo origin https://github.com/shenv/shenv.git' \
    "describe --tags HEAD : echo v1984-12-gSHA"
  run shell-build --version
  assert_success "shell-build 1984-12-gSHA"
  unstub git
}

@test "git describe fails" {
  stub git \
    'remote -v : echo origin https://github.com/shenv/shenv.git' \
    "describe --tags HEAD : echo ASPLODE >&2; exit 1"
  run shell-build --version
  assert_success "shell-build ${static_version}"
  unstub git
}

@test "git remote doesn't match" {
  stub git \
    'remote -v : echo origin https://github.com/Homebrew/homebrew.git' \
    "describe --tags HEAD : echo v1984-12-gSHA"
  run shell-build --version
  assert_success "shell-build ${static_version}"
}
