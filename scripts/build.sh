#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

DEVICE="${1:-$CIQ_DEVICE}"
if [ -n "$CIQ_BUILD_SUFFIX" ]; then
    DEFAULT_OUT="$BUILD_DIR/$APP_NAME-$CIQ_BUILD_SUFFIX-$DEVICE.prg"
else
    DEFAULT_OUT="$BUILD_DIR/$APP_NAME-$DEVICE.prg"
fi
OUT="${2:-$DEFAULT_OUT}"

ciq_require_sdk
ciq_require_file "$PROJECT_DIR/$CIQ_JUNGLE"
ciq_ensure_key
mkdir -p "$BUILD_DIR"

printf 'Building %s for %s using %s\n' "$APP_NAME" "$DEVICE" "$CIQ_JUNGLE"
(
    cd "$PROJECT_DIR"
    "$MONKEYC" -f "$CIQ_JUNGLE" -d "$DEVICE" -o "$OUT" -y "$CIQ_KEY" -w
)

printf 'Built: %s\n' "$OUT"
