#!/bin/bash
set -uo pipefail
K=/root/rebuild/kernel-daily.macho
echo "=== qcom-usb-debug / USDA 相关 ==="
strings -a "$K" 2>/dev/null | grep -iE 'qcom-usb|usb-debug|usbdebug|QcomXnuUsb' | sort -u | head -15 | cut -c1-140
echo
echo "=== 内核里的 USB 相关字符串（前 25 条）==="
strings -a "$K" 2>/dev/null | grep -iE '\busb\b' | sort -u | head -25 | cut -c1-130
