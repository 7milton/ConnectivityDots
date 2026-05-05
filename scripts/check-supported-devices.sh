#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

EXPECTED="$(mktemp)"
ACTUAL="$(mktemp)"
cleanup() {
    rm -f "$EXPECTED" "$ACTUAL"
}
trap cleanup EXIT

"$SCRIPT_DIR/list-complication-devices.sh" > "$EXPECTED"
sed -n 's/.*<iq:product id="\([^"]*\)".*/\1/p' "$PROJECT_DIR/manifest.xml" | sort > "$ACTUAL"

expected_count="$(wc -l < "$EXPECTED" | tr -d ' ')"
actual_count="$(wc -l < "$ACTUAL" | tr -d ' ')"

printf 'SDK complication watch devices: %s\n' "$expected_count"
printf 'Manifest products:              %s\n' "$actual_count"

missing="$(comm -23 "$EXPECTED" "$ACTUAL" || true)"
extra="$(comm -13 "$EXPECTED" "$ACTUAL" || true)"

if [ -n "$missing" ]; then
    printf '\nMissing from manifest:\n%s\n' "$missing" >&2
fi

if [ -n "$extra" ]; then
    printf '\nIn manifest but not detected as complication watches:\n%s\n' "$extra" >&2
fi

if [ -n "$missing$extra" ]; then
    exit 1
fi

printf 'Supported device list matches local SDK.\n'
