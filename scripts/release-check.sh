#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

DEVICE="${1:-$CIQ_DEVICE}"

"$SCRIPT_DIR/check-private-data.sh"
"$SCRIPT_DIR/test.sh" "$DEVICE"
"$SCRIPT_DIR/build.sh" "$DEVICE"

if [ "${CIQ_VALIDATE_NOWIFI:-0}" = "1" ]; then
    "$SCRIPT_DIR/build-no-wifi.sh" "$CIQ_NOWIFI_DEVICE"
fi

"$SCRIPT_DIR/export-iq.sh" "$CIQ_KEY"

printf 'Release check completed.\n'
