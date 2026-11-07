#!/bin/bash
set -uo pipefail
D=/root/fuxi/logs/usb3/untagged-2d4aaa003
echo "=== msgbuf 里 USB 相关 ==="
tr -d '\0' < "$D/msgbuf.txt" | grep -aiE 'usb|vbus|dwc|cdc|acm|qcom|udc|phy|type-?c' | head -40 | cut -c1-200
echo
echo "=== msgbuf 头尾（看覆盖时间范围）==="
tr -d '\0' < "$D/msgbuf.txt" | head -3 | cut -c1-160
tr -d '\0' < "$D/msgbuf.txt" | tail -3 | cut -c1-160
echo
echo "=== slots 里 USB 相关 ==="
grep -aiE 'usb|vbus|dwc3|cdc|qcom_usb' "$D/slots.txt" | head -30 | cut -c1-200
