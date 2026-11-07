#!/bin/bash
set -uo pipefail
L="/mnt/e/xwechat_files/wxid_ufcunrrmn9p22_4361/msg/file/2026-11/fuxi-20190100-002043.log"
ls -l "$L" 2>/dev/null || { echo "找不到日志"; exit 1; }
cp "$L" /root/fuxi/fuxi-fw.log
echo "=== 行数 ==="
wc -l < /root/fuxi/fuxi-fw.log
echo
echo "=== USB / VBUS / TypeC / 充电 相关行 ==="
grep -inE 'usb|vbus|typec|type-c|ucsi|charg|dwc|cdc|acm|xhci' /root/fuxi/fuxi-fw.log | head -60 | cut -c1-190
