#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

fail=0

report_path() {
    printf 'Private/generated file should not be in the release tree: %s\n' "$1" >&2
    fail=1
}

while IFS= read -r -d '' path; do
    case "$path" in
        "$PROJECT_DIR/build/"*|"$PROJECT_DIR/bin/"*|"$PROJECT_DIR/result/"*)
            continue
            ;;
    esac

    report_path "$path"
done < <(
    find "$PROJECT_DIR" -type f \( \
        -name '*.der' -o \
        -name '*.pem' -o \
        -name '*.key' -o \
        -name 'developer_key' -o \
        -name '*.prg' -o \
        -name '*.iq' -o \
        -name '*.debug.xml' \
    \) -print0
)

scan_file() {
    local file="$1"

    case "$file" in
        "$PROJECT_DIR/.gitignore"|"$SCRIPT_DIR/check-private-data.sh"|"$PROJECT_DIR/build/"*|"$PROJECT_DIR/bin/"*|"$PROJECT_DIR/result/"*)
            return
            ;;
    esac

    if LC_ALL=C grep -I -n -E '/Users/|dominik|IdeaProjects' "$file" >/tmp/connectivity-dots-private-scan.$$ 2>/dev/null; then
        printf 'Private path/name pattern found in %s:\n' "$file" >&2
        sed 's/^/  /' /tmp/connectivity-dots-private-scan.$$ >&2
        fail=1
    fi

    rm -f /tmp/connectivity-dots-private-scan.$$
}

while IFS= read -r -d '' file; do
    scan_file "$file"
done < <(find "$PROJECT_DIR" -type f -print0)

WORKSPACE_FILE="$WORKSPACE_DIR/ConnectivityDots.code-workspace"
if [ -f "$WORKSPACE_FILE" ]; then
    scan_file "$WORKSPACE_FILE"
fi

if [ -d "$WORKSPACE_DIR/ConnectivityDotsTestFace" ]; then
    printf 'Dev-only test face directory must not be present in the release tree: %s\n' "$WORKSPACE_DIR/ConnectivityDotsTestFace" >&2
    fail=1
fi

if [ "$fail" -ne 0 ]; then
    exit 1
fi

printf 'Private data scan passed.\n'
