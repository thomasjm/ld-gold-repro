#!/usr/bin/env bash
set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPTDIR"

set +e
OUTPUT=$(nix build .#calculateMaterializedSha --no-link --json | jq -r '.[0].outputs.out')
EXIT_CODE=$?
if [[ "$EXIT_CODE" -ne 0 ]]; then
    STACK_SHA256=$(echo "$OUTPUT" | grep "stack-sha256 = \".*\";" | sed -E 's/\s*stack-sha256 = "(.*)";\s*/\1/g')
    SCRIPT=$(echo "$OUTPUT" | grep "To fix run: /nix/.*" | sed -E 's|.*To fix run: (/nix/.*)|\1|g')
else
    STACK_SHA256=$(bash "$OUTPUT")
    SCRIPT=$(nix build .#generateMaterialized --no-link --json | jq -r '.[0].outputs.out')
fi

# Update stack-sha256
if [[ -n "$STACK_SHA256" ]]; then
    echo "Got stack-sha256: $STACK_SHA256"
    sed -i "s/stack-sha256 = .*;/stack-sha256 = \"$STACK_SHA256\";/g" default.nix
else
    echo "Error, didn't get stack-sha256!"
fi

# Update materialization
if [[ -n "$SCRIPT" ]]; then
    echo "Got script: $SCRIPT"
    "$SCRIPT" "$SCRIPTDIR/materialized"
else
    echo "Error, didn't get script!"
fi
