#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/l-usb3.bin
D=/root/fuxi/logs/usb3/untagged-2d4aaa003
echo "=== 原始区里的段标记 ==="
for m in SHLOG001 SHUEFI01 SHNGROOT; do
  n=$(grep -aob "$m" "$B" 2>/dev/null | head -5 | tr '\n' ' ')
  printf '  %-10s %s\n' "$m" "${n:-（没有）}"
done
echo
echo "=== slots.txt 开头（最早的快照）==="
head -25 "$D/slots.txt" | cut -c1-180
echo
echo "=== slots.txt 里有没有更早的启动行 ==="
grep -aniE 'Boot|early|DarwinBoot|XNU|panic|assert' "$D/slots.txt" | head -12 | cut -c1-180
