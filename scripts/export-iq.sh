#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

KEY="${1:-$CIQ_KEY}"
OUT="${2:-$BUILD_DIR/$APP_NAME.iq}"

ciq_require_sdk
ciq_require_file "$PROJECT_DIR/monkey.jungle"
if [ "$KEY" = "$CIQ_KEY" ]; then
    ciq_ensure_key
else
    ciq_require_file "$KEY"
fi
mkdir -p "$BUILD_DIR"

printf 'Exporting %s\n' "$APP_NAME"
(
    cd "$PROJECT_DIR"
    "$MONKEYC" -e -f monkey.jungle -o "$OUT" -y "$KEY" -w
)

printf 'Exported: %s\n' "$OUT"
