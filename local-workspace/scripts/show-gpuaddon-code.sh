#!/bin/bash
set -uo pipefail
echo "=== payload.py 里 gpuaddon 的处理 ==="
grep -n -B3 -A12 'gpuaddon' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/payload.py 2>/dev/null | head -50 | cut -c1-170
echo
echo "=== 旧 addon 文件在哪 ==="
find /root/fuxi /mnt/e/DSH-Fuxi -name 'kernel.macho.gpuaddon' 2>/dev/null | head -5
