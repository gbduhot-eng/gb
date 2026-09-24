#!/bin/sh
# Fast lint tier. Keep this out of xcodebuild — same reason the ESLint
# prompt keeps lint:types out of the compile: a gate people bypass is
# not a gate.
set -e
cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
if ! command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint is not on PATH. Install with: brew install swiftlint" >&2
  exit 1
fi
exec swiftlint lint "$@"
