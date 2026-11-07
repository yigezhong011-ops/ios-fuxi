#!/bin/bash
# The driver skips the bootstrap pass when osfmk's compile record exists, but the
# record survived a pass whose link failed, so no link.filelist was written and
# the archive step cannot start. Drop the record to force a fresh bootstrap.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true

DEV=/root/fuxi/fork-device
OUT=/root/ux2
TREE=$OUT/fuxi/tree
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi

echo "=== 删除编译记录 ==="
find "$TREE/build/xnu/ios-obj" -name 'startup.o.json' -delete -print 2>/dev/null | head -3
find "$TREE/build/xnu/ios-obj" -name 'link.filelist' -delete 2>/dev/null

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-build.log
: > "$LOG"
echo "=== 重新编译（bootstrap 会再跑一次）==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "kernel exit=$code"
echo "=== 未定义符号 ==="
grep -o '"_[_a-zA-Z][_a-zA-Z0-9]*"' "$TREE/../logs/kernel-bootstrap.log" 2>/dev/null | sort -u | head -14
echo "=== 错误 ==="
grep -n 'error:' "$LOG" 2>/dev/null | head -5 | cut -c1-170
tail -8 "$LOG" | cut -c1-170
