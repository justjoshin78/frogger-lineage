#!/usr/bin/env bash
# Build LineageOS 23.2 for frogger in a clean environment.
# Usage: LINEAGE_TOP=/path/to/lineage-23.2 ./build_frogger.sh [make target, default: bacon] [jobs, default: nproc]
# A clean env avoids shell profile wrappers (for example a grep alias) that break envsetup.sh/lunch.
TOP="${LINEAGE_TOP:?set LINEAGE_TOP to your lineage-23.2 checkout}"
TARGET="${1:-bacon}"
JOBS="${2:-$(nproc)}"
LOG="$TOP/../frogger-build-$(date +%Y%m%d-%H%M).log"
exec env -i HOME="$HOME" USER="$USER" TERM=dumb LANG=C.UTF-8 \
  PATH=/usr/local/bin:/usr/bin:/bin \
  USE_CCACHE="${USE_CCACHE:-1}" CCACHE_EXEC="${CCACHE_EXEC:-/usr/bin/ccache}" \
  ${CCACHE_DIR:+CCACHE_DIR="$CCACHE_DIR"} \
  bash --noprofile --norc -c "
    set -o pipefail
    cd '$TOP' || exit 1
    source build/envsetup.sh >/dev/null
    breakfast frogger userdebug >/dev/null || exit 1
    echo \"Log: $LOG\"
    m $TARGET -j$JOBS 2>&1 | tee '$LOG'
  "
