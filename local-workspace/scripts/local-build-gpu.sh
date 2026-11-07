#!/bin/bash
# Local (Linux) build attempt with the current device fork: GPU config, no PMGR
# archive, link stubs, board ZAP pin.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
PREFIX=$HOME/.local/xnu-linux
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true

DEV=/root/fuxi/fork-device
OUT=/root/ux2
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1

echo "=== 1) 设备仓库状态 ==="
git -C "$DEV" log --oneline -2
ls "$DEV/configs" | tr '\n' ' '; echo

echo "=== 2) defconfig ==="
./unixnu defconfig fuxi_gpu_defconfig -D "$DEV" --out "$OUT" --uefi "$UEFI" 2>&1 | tail -3

echo "=== 3) 组装树 ==="
LOG=/root/local-build.log
: > "$LOG"
./unixnu tree -D "$DEV" --out "$OUT" --uefi "$UEFI" >>"$LOG" 2>&1
echo "   tree exit=$? ($(wc -l < "$LOG") 行)"

echo "=== 4) 建 stub 归档到设备仓库 ==="
python3 "$DEV/scripts/build-fuxi-link-stubs.py" 2>&1 | tail -2 || echo "  （stub 脚本需要在 macOS 上跑，先跳过）"

echo "=== 5) 编内核（后台日志 /root/local-build.log）==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j"$(nproc)" >>"$LOG" 2>&1
code=$?
echo "   kernel exit=$code"
tail -15 "$LOG"
