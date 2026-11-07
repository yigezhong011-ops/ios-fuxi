#!/bin/bash
# Build the loader: it carries the iPhone identity taken from our own IPSW.
set -uo pipefail
LOG=/root/hakios-loader.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="
cd /root/hakios-xnu-kernel || exit 1

echo "--- 工具 ---"
for t in clang lld lld-link ld64.lld; do printf '%-10s ' "$t"; command -v $t >/dev/null && echo OK || echo 缺; done

echo "--- make loader ---"
make loader 2>&1 | tail -30

echo "=== 产物 ==="
ls -lh loader.efi xnuloader/*.efi 2>/dev/null
echo "=== $(date) 结束 ==="
