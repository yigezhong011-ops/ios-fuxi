#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== prebuilt ==="
ls -lh prebuilt/ 2>/dev/null | head -15
echo
echo "=== docs ==="
ls docs/ 2>/dev/null | head -20
echo
echo "=== xnuloader 里的设备相关常量 ==="
grep -n -i -E 'redwood|0xA[0-9A-F]{6,}|0x1[0-9A-F]{6,}|uart|UART|sm[0-9]{4}|soc' xnuloader/loader.c | head -30
