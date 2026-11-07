#!/bin/bash
set -uo pipefail
D=/root/fuxi/logs/usb3/untagged-2d4aaa003
echo "=== slots.txt 里 USB 的 trace 行 ==="
grep -a -n 'USB ph=' "$D/slots.txt" | head -10
echo "--- 任意 usb 字样 ---"
grep -a -n -i 'usb' "$D/slots.txt" | head -8 | cut -c1-160
echo
echo "=== slots.txt 里的段名 ===
"
grep -a -o '^\[[a-z ]*\]' "$D/slots.txt" | sort | uniq -c | sort -rn | head -12
