#!/bin/bash
set -euo pipefail
exec > >(tee /root/unixnu-fw.log) 2>&1

echo "=== 1. 准备设备仓库 ==="
DEV=/root/UniXNU-fuxi
rm -rf "$DEV"
mkdir -p "$DEV/configs" "$DEV/dts" "$DEV/patches/xnu"
cp /mnt/e/DSH-Fuxi/unixnu/fuxi-board.toml "$DEV/board.toml"
cp /mnt/e/DSH-Fuxi/unixnu/feeds.toml "$DEV/feeds.toml"
cp /mnt/e/DSH-Fuxi/unixnu/fuxi_defconfig "$DEV/configs/fuxi_defconfig"
cp /mnt/e/DSH-Fuxi/unixnu/fuxi.dts "$DEV/dts/fuxi.dts"
: > "$DEV/patches/xnu/series"
ls -R "$DEV"

echo "=== 2. defconfig ==="
cd /root/UniXNU
python3 ./unixnu defconfig fuxi_defconfig -D "$DEV" 2>&1 | tail -15

echo "=== 3. status ==="
python3 ./unixnu status --json -D "$DEV" 2>&1 | head -40
echo DEVICE_READY
