#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

DEVICE="${1:-$CIQ_DEVICE}"
if [ -n "$CIQ_BUILD_SUFFIX" ]; then
    PRG="$BUILD_DIR/$APP_NAME-$CIQ_BUILD_SUFFIX-$DEVICE.prg"
else
    PRG="$BUILD_DIR/$APP_NAME-$DEVICE.prg"
fi

"$SCRIPT_DIR/build.sh" "$DEVICE" "$PRG"
"$SCRIPT_DIR/start-simulator.sh"

printf 'Running %s on %s\n' "$APP_NAME" "$DEVICE"
if ! "$MONKEYDO" "$PRG" "$DEVICE"; then
    printf '\nUnable to connect/run on the simulator.\n' >&2
    printf 'Try restarting the simulator with:\n' >&2
    printf '  CIQ_RESTART_SIMULATOR=1 %s %s\n' "$0" "$DEVICE" >&2
    exit 1
fi
