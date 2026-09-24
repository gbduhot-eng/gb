#!/bin/sh
# Self-check that the copied .swiftlint.yml still contains the two gates.
# Does not need SourceKit. Three lines ending in ": ok", exit 0.
set -e
config="${1:-.swiftlint.yml}"
if [ ! -f "$config" ]; then
  echo "missing $config" >&2
  exit 1
fi

ok() {
  rule="$1"
  if grep -q "$rule" "$config"; then
    echo "$rule: ok"
  else
    echo "$rule: missing from $config" >&2
    exit 1
  fi
}

ok "file_length"
ok "no_direct_print"

if grep -q "only_rules:" "$config"; then
  echo "only_rules: ok"
else
  echo "only_rules: missing — without it SwiftLint enables the whole style guide" >&2
  exit 1
fi
