#!/bin/bash
# Unpack the Darwin userland 16.5 pieces HakiOS builds its system image from.
set -uo pipefail
LOG=/root/hakios-unpack.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

echo "--- 安装 7zip（23+ 支持 APFS）---"
apt-get install -y -q 7zip 2>&1 | tail -3
7z 2>/dev/null | head -2

cd /root/hakios-xnu-kernel || exit 1
IPSW='/mnt/e/DSH-Fuxi/ipsw16.5/iPhone10,3,iPhone10,6_16.5_20F66_Restore.ipsw'
ls -lh "$IPSW"

echo "--- 解包 ---"
bash sysimage/unpack.sh "$IPSW" 2>&1 | tail -40

echo "=== 结果 ==="
ls sysimage 2>/dev/null | head -15
du -sh sysimage 2>/dev/null
echo "=== $(date) 结束 ==="
