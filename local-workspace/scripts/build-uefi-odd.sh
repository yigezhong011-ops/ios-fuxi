#!/bin/bash
# Build the fuxi firmware from the OddlyLabs UEFI fork (their README says Linux works).
set -uo pipefail
LOG=/root/uefi-odd-build.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="
cd /root/uefi-odd || exit 1

echo "--- fuxi 平台 ---"
ls Platforms/Xiaomi/ | grep -i fuxi || echo "  没有 fuxiPkg！"

echo "--- 依赖 ---"
apt-get install -y -q uuid-dev 2>&1 | tail -2
python3 -m pip install -q --break-system-packages -r pip-requirements.txt 2>&1 | tail -3

echo "--- 构建 ---"
python3 build_uefi.py -d fuxi -r DEBUG 2>&1 | tail -40

echo "=== 产物 ==="
find . -name '*.fd' 2>/dev/null | head -5
ls -l Build/fuxiPkg/*/FV/*.fd 2>/dev/null
echo "=== $(date) 结束 ==="
