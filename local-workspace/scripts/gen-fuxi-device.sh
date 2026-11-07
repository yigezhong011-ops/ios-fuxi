#!/bin/bash
# Generate the fuxi device repository from its own device tree.
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
DTB=/root/fuxi/fork-device/package/fuxi.dtb
ls -l "$DTB"
echo "=== 生成设备仓库 ==="
python3 tools/hakios-device.py new fuxi \
  --soc sm8550 \
  --soc-title "Snapdragon 8 Gen 2" \
  --title "Xiaomi 13" \
  --vendor Xiaomi \
  --maintainer dsh \
  --fdt "$DTB" 2>&1 | tail -25
echo
echo "=== 生成结果 ==="
ls devices/fuxi 2>/dev/null
echo "=== soc 层 ==="
ls soc/sm8550 2>/dev/null | head
echo "=== 检查 ==="
python3 tools/hakios-device.py check fuxi 2>&1 | tail -15
