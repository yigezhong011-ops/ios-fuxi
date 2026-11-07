#!/bin/bash
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
echo "=== 有 nasm 吗 ==="
which nasm || echo "没有"
echo "=== build_uefi.py 的用法 ==="
python3 "$U/build_uefi.py" --help 2>&1 | head -25
