#!/usr/bin/env bash

# Shared Connect IQ script configuration.
# Override any value by exporting the matching environment variable before running a script.

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$CONFIG_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

if [ -f "$CONFIG_DIR/config.local.sh" ]; then
    # Optional per-machine overrides. Keep this file out of release packages if it contains private paths.
    # shellcheck source=./config.local.sh
    source "$CONFIG_DIR/config.local.sh"
fi

APP_NAME="ConnectivityDots"
BUILD_DIR="${CIQ_BUILD_DIR:-$PROJECT_DIR/build}"

CIQ_DEVICE="${CIQ_DEVICE:-epix2pro51mm}"
CIQ_NOWIFI_DEVICE="${CIQ_NOWIFI_DEVICE:-fenix7pronowifi}"
CIQ_JUNGLE="${CIQ_JUNGLE:-monkey.jungle}"
CIQ_TEST_JUNGLE="${CIQ_TEST_JUNGLE:-monkey-test.jungle}"
CIQ_BUILD_SUFFIX="${CIQ_BUILD_SUFFIX:-}"

ciq_die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

ciq_find_sdk() {
    if [ -n "${CIQ_SDK:-}" ]; then
        printf '%s\n' "$CIQ_SDK"
        return
    fi

    local sdk_root
    sdk_root="${CIQ_SDK_ROOT:-$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks}"

    local newest
    newest="$(ls -td "$sdk_root"/connectiq-sdk-* 2>/dev/null | head -n 1 || true)"
    if [ -z "$newest" ]; then
        ciq_die "Connect IQ SDK not found. Set CIQ_SDK=/path/to/connectiq-sdk-*"
    fi

    printf '%s\n' "$newest"
}

CIQ_SDK="$(ciq_find_sdk)"
MONKEYC="$CIQ_SDK/bin/monkeyc"
MONKEYDO="$CIQ_SDK/bin/monkeydo"
CONNECTIQ="$CIQ_SDK/bin/connectiq"
DEFAULT_CIQ_KEY="$BUILD_DIR/connectiq_dev_key.der"
CIQ_KEY="${CIQ_KEY:-$DEFAULT_CIQ_KEY}"

ciq_require_file() {
    [ -f "$1" ] || ciq_die "Missing file: $1"
}

ciq_require_dir() {
    [ -d "$1" ] || ciq_die "Missing directory: $1"
}

ciq_require_exec() {
    [ -x "$1" ] || ciq_die "Missing executable: $1"
}

ciq_require_sdk() {
    ciq_require_exec "$MONKEYC"
    ciq_require_exec "$MONKEYDO"
    ciq_require_exec "$CONNECTIQ"
}

ciq_ensure_key() {
    mkdir -p "$BUILD_DIR"

    if [ -f "$CIQ_KEY" ]; then
        return
    fi

    if [ "$CIQ_KEY" != "$DEFAULT_CIQ_KEY" ]; then
        ciq_die "Configured CIQ_KEY does not exist: $CIQ_KEY"
    fi

    command -v openssl >/dev/null 2>&1 || ciq_die "openssl not found; cannot create local dev key"

    local pem_key
    pem_key="${CIQ_KEY%.der}.pem"

    printf 'Creating local development key: %s\n' "$CIQ_KEY"
    openssl genrsa -out "$pem_key" 4096 >/dev/null 2>&1
    openssl pkcs8 -topk8 -inform PEM -outform DER -in "$pem_key" -out "$CIQ_KEY" -nocrypt
    chmod 600 "$pem_key" "$CIQ_KEY"
}

ciq_print_config() {
    printf 'SDK:        %s\n' "$CIQ_SDK"
    printf 'Device:     %s\n' "$CIQ_DEVICE"
    printf 'No-WiFi:    %s\n' "$CIQ_NOWIFI_DEVICE"
    printf 'Key:        %s\n' "$CIQ_KEY"
    printf 'Build dir:  %s\n' "$BUILD_DIR"
    printf 'Jungle:     %s\n' "$CIQ_JUNGLE"
    printf 'Test jungle: %s\n' "$CIQ_TEST_JUNGLE"
}

ciq_simulator_is_running() {
    if ! command -v pgrep >/dev/null 2>&1; then
        return 1
    fi

    pgrep -f "ConnectIQ\\.app/Contents" >/dev/null 2>&1
}

ciq_stop_simulator() {
    if ! command -v pkill >/dev/null 2>&1; then
        return 0
    fi

    pkill -f "ConnectIQ\\.app/Contents" >/dev/null 2>&1 || true
}
