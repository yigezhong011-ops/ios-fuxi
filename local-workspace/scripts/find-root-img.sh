#!/bin/bash
set -uo pipefail
echo "=== E: 上的 root 镜像 ==="
ls -lh /mnt/e/DSH-Fuxi/*.img 2>/dev/null | head -6
echo
echo "=== 所有脚本里出现 dylib 的地方 ==="
grep -rln 'dylib' /mnt/e/DSH-Fuxi/dump/wsl/ 2>/dev/null | head -8
echo
echo "=== 最新的 root 构建脚本内容（前 40 行）==="
ls -t /mnt/e/DSH-Fuxi/dump/wsl/step2*.sh 2>/dev/null | head -3
