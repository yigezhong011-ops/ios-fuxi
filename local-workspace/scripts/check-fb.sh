#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon5/boot.log
echo "=== SWEET FB / 呈现 相关 ==="
grep -a -n 'SWEET FB' "$L" | head -20 || echo "(none)"
echo
echo "=== swap / present / IOSurface ==="
grep -a -niE 'swap|present|iosurface|surface' "$L" | head -25 || echo "(none)"
echo
echo "=== 显示控制器相关（CTL/INTF/DSI）==="
grep -a -niE 'CTL|INTF|DSI|panel|scanout' "$L" | head -20 || echo "(none)"
