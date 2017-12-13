#!/bin/sh
# Usage: PREFIX=/usr/local ./install.sh
#
# Installs shell-build under $PREFIX.

set -e

cd "$(dirname "$0")"

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"
SHARE_PATH="${PREFIX}/share/shell-build"

mkdir -p "$BIN_PATH" "$SHARE_PATH"

install -p bin/* "$BIN_PATH"
for share in share/shell-build/*; do
  if [ -d "$share" ]; then
    cp -RPp "$share" "$SHARE_PATH"
  else
    install -p -m 0644 "$share" "$SHARE_PATH"
  fi
done
