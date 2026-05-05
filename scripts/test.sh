#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

DEVICE="${1:-$CIQ_DEVICE}"
OUT="${2:-$BUILD_DIR/$APP_NAME-tests-$DEVICE.prg}"

ciq_require_sdk
ciq_require_file "$PROJECT_DIR/$CIQ_TEST_JUNGLE"
ciq_ensure_key
mkdir -p "$BUILD_DIR"

printf 'Building unit tests for %s on %s using %s\n' "$APP_NAME" "$DEVICE" "$CIQ_TEST_JUNGLE"
(
    cd "$PROJECT_DIR"
    "$MONKEYC" -t -f "$CIQ_TEST_JUNGLE" -d "$DEVICE" -o "$OUT" -y "$CIQ_KEY" -w
)

"$SCRIPT_DIR/start-simulator.sh"

printf 'Running unit tests for %s on %s\n' "$APP_NAME" "$DEVICE"
CIQ_TEST_TIMEOUT_SECONDS="${CIQ_TEST_TIMEOUT_SECONDS:-60}"

"$MONKEYDO" "$OUT" "$DEVICE" -t &
monkeydo_pid="$!"
deadline="$((SECONDS + CIQ_TEST_TIMEOUT_SECONDS))"

while kill -0 "$monkeydo_pid" 2>/dev/null; do
    if [ "$SECONDS" -ge "$deadline" ]; then
        pkill -P "$monkeydo_pid" 2>/dev/null || true
        kill "$monkeydo_pid" 2>/dev/null || true
        wait "$monkeydo_pid" 2>/dev/null || true
        ciq_die "Unit test run timed out after ${CIQ_TEST_TIMEOUT_SECONDS}s"
    fi

    sleep 1
done

wait "$monkeydo_pid"
