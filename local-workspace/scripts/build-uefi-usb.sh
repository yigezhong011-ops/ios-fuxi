#!/bin/bash
# Build the fuxi firmware with the USB power enabler (DEBUG so AdvancedLogDxe is included).
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
LOG=/root/uefi-build.log
cd "$U" || exit 1
: > "$LOG"
echo "=== $(date) 固件构建开始 ===" | tee -a "$LOG"
export WORKSPACE="$U"
python3 build_uefi.py -d fuxi -r DEBUG >>"$LOG" 2>&1
rc=$?
echo "=== $(date) 结束, exit=$rc ===" | tee -a "$LOG"
tail -40 "$LOG"
find "$U" -name '*.fd' -newermt '-2 hours' 2>/dev/null | head -5
