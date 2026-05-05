#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

exec "$SCRIPT_DIR/build.sh" "${1:-$CIQ_NOWIFI_DEVICE}" "${2:-$BUILD_DIR/$APP_NAME-${1:-$CIQ_NOWIFI_DEVICE}.prg}"
