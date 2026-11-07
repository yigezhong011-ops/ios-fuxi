#!/bin/bash
# Build the system image (root.apfs + the payload pieces) from the unpacked IPSW.
set -uo pipefail
LOG=/root/hakios-userland.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="
cd /root/hakios-xnu-kernel || exit 1
export REST=1
bash userland/build.sh 2>&1 | tail -50
echo "=== 产物 ==="
find . -name '*.apfs' -newermt '-1 hour' 2>/dev/null | head -5
ls -lh root.apfs system.apfs 2>/dev/null
echo "=== $(date) 结束 ==="
