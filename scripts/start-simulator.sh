#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

ciq_require_sdk

if [ "${CIQ_RESTART_SIMULATOR:-0}" = "1" ]; then
    printf 'Restarting Connect IQ simulator...\n'
    ciq_stop_simulator
    sleep 1
fi

if ciq_simulator_is_running; then
    printf 'Connect IQ simulator already appears to be running.\n'
    exit 0
fi

printf 'Starting Connect IQ simulator...\n'
"$CONNECTIQ" >/dev/null 2>&1 &
sleep "${CIQ_SIM_START_DELAY:-8}"
printf 'Simulator started.\n'
