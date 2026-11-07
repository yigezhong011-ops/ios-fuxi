#!/bin/bash
# Clone HakiOS into E: and show what the main repository carries.
set -uo pipefail
cd /mnt/e/DSH-Fuxi
rm -rf hakios
git clone -q --depth 1 https://github.com/oosexgang/hakios.git hakios 2>&1 | tail -3
if [ ! -d hakios ]; then
  echo "主仓库名不对，试其他："
  for name in hakios-main hakios-kernel; do
    git clone -q --depth 1 "https://github.com/oosexgang/$name.git" "hakios-$name" 2>/dev/null && echo "  克隆到 hakios-$name"
  done
  exit 1
fi
cd hakios
echo "=== 顶层 ==="
ls | head -30
echo
echo "=== tools ==="
ls tools 2>/dev/null | head -20
echo
echo "=== README 前 40 行 ==="
head -40 README.md 2>/dev/null | cut -c1-140
