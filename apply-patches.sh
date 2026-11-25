#!/usr/bin/env bash
# Apply the small build fixes in patches/ to a synced lineage-23.2 tree.
# Usage: ./apply-patches.sh /path/to/lineage-23.2
# Each patch file is named after its project path with "/" replaced by "_".
set -euo pipefail
TOP="$(cd "${1:?usage: $0 /path/to/lineage-23.2}" && pwd)"
HERE="$(cd "$(dirname "$0")" && pwd)"
for patch in "$HERE"/patches/*.patch; do
    name="$(basename "$patch" .patch)"
    case "$name" in
        external_*)        path="external/${name#external_}" ;;
        hardware_qcom-caf_*) rest="${name#hardware_qcom-caf_}"; path="hardware/qcom-caf/${rest%%_*}/${rest#*_}"
                           [ "$rest" = common ] && path="hardware/qcom-caf/common" ;;
        *) echo "Unknown patch name: $name" >&2; exit 1 ;;
    esac
    if git -C "$TOP/$path" apply --reverse --check "$patch" 2>/dev/null; then
        echo "already applied: $path"
    else
        git -C "$TOP/$path" apply "$patch"
        echo "applied:         $path"
    fi
done
