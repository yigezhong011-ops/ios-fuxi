#!/bin/bash
set -uo pipefail
echo "=== 7z 版本（需要 23+ 才能读 APFS）==="
7z 2>/dev/null | head -3 || echo "7z 未安装"
7zz 2>/dev/null | head -3 || true
echo
echo "=== cc ==="
command -v cc >/dev/null && cc --version | head -1 || echo "cc 缺"
echo
echo "=== 磁盘 ==="
df -h /root /mnt/e | tail -3
