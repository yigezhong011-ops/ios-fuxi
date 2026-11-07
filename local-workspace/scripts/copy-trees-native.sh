#!/bin/bash
# Copy the build trees to WSL's native filesystem: git operations and EDK2 builds fail on
# the 9p mount (index.lock: Bad file descriptor).
set -uo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-build
DST=/root/build
mkdir -p "$DST"
LOG=/root/copy-build.log
: > "$LOG"

for d in unixnu fuxi uefi-fuxi; do
  echo "=== $d ===" | tee -a "$LOG"
  du -sh "$SRC/$d" 2>/dev/null | tee -a "$LOG"
  rsync -a --delete "$SRC/$d/" "$DST/$d/" >>"$LOG" 2>&1
  echo "  rsync exit=$?  $(du -sh "$DST/$d" 2>/dev/null | cut -f1)" | tee -a "$LOG"
done
echo "=== 拷贝完成 $(date) ===" | tee -a "$LOG"
