#!/bin/bash
# Is data-raw.img an APFS container start? Check for NXSB and the block-0 fields.
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/logs/data-raw.img
echo "=== 前 64 字节（hex）==="
head -c 64 "$IMG" | xxd | head -4
echo
echo "=== 是否含 APFS 容器魔数 NXSB ==="
head -c 4096 "$IMG" | grep -c NXSB || true
echo
echo "=== 前 4 KiB 里的可打印串 ==="
head -c 4096 "$IMG" | strings -a | head -10
echo
echo "=== 找 NXSB 在整个镜像里出现的位置（前 5 个）==="
grep -aob 'NXSB' "$IMG" 2>/dev/null | head -5
