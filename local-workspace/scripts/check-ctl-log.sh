#!/bin/bash
# Did the control channel come up, and did it see our frames?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/com3-t50-auto-touch-223549.log
echo "=== 文件 $(du -h "$L" | cut -f1) ==="
echo
echo "=== 控制通道相关 ==="
for k in 'SXNU1' 'HELLO' 'SCREENSHOT' 'control' 'usb-debug' 'usb_debug' 'sxnu' 'qcom-usb'; do
  printf '  %-14s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 含 usb 的启动消息（前 12）==="
grep -a -i 'usb' "$L" | head -12 | cut -c1-170
echo
echo "=== 最后 5 行 ==="
tail -5 "$L" | cut -c1-170
