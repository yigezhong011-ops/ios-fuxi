#!/bin/bash
set -uo pipefail
K=/root/rebuild/kernel-daily.macho
echo "=== sweet_usb / USB 设备模式 相关字符串 ==="
for pat in 'sweetusb' '192.168.7' '5140' '02:00:5e:77:ee:01' 'sweet_usb' 'CDC-ECM' 'sweetconsole' 'sweetlog'; do
  n=$(strings -a "$K" 2>/dev/null | grep -c -- "$pat" || true)
  printf '%-22s %s\n' "$pat" "$n"
done
echo
echo "=== 具体匹配 ==="
strings -a "$K" 2>/dev/null | grep -E 'sweetusb|192\.168\.7|:5140|sweet_usb' | sort -u | head -12 | cut -c1-140
echo
echo "=== 相关启动参数 ==="
strings -a "$K" 2>/dev/null | grep -E '^sweet[a-z-]+$' | sort -u | head -20
