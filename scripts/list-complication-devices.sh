#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./config.sh
source "$SCRIPT_DIR/config.sh"

command -v jq >/dev/null 2>&1 || ciq_die "jq not found"

DEVICES_DIR="${CIQ_DEVICES_DIR:-$HOME/Library/Application Support/Garmin/ConnectIQ/Devices}"
ciq_require_dir "$DEVICES_DIR"

DETAILS=0
if [ "${1:-}" = "--details" ]; then
    DETAILS=1
fi

find "$DEVICES_DIR" -maxdepth 2 -name compiler.json -print0 |
    xargs -0 jq -r --argjson details "$DETAILS" '
        def parts($v): ($v // "0.0.0" | split(".") | map(tonumber? // 0));
        def version_at_least($min):
            (parts(.) + [0, 0, 0]) as $v |
            (parts($min) + [0, 0, 0]) as $m |
            ($v[0] > $m[0]) or
            ($v[0] == $m[0] and $v[1] > $m[1]) or
            ($v[0] == $m[0] and $v[1] == $m[1] and $v[2] >= $m[2]);

        select(
            .complicationIcon != null and
            .webDocDeviceGroup == "Watches/Wearables" and
            any(.appTypes[]?; .type == "watchApp") and
            any(.partNumbers[]?; (.connectIQVersion // "0.0.0" | version_at_least("4.2.0")))
        ) |
        if $details == 1 then
            [.deviceId, .displayName, .deviceGroup, (.partNumbers[0].connectIQVersion // "")] | @tsv
        else
            .deviceId
        end
    ' |
    sort
