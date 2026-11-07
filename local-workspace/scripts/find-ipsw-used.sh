#!/bin/bash
set -uo pipefail
echo "=== 我们构建 root 时用的 IPSW / 设备 ==="
grep -rn -i 'ipsw\|d22ap\|iphone10\|ipad' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | grep -v 'check-\|look-\|find-\|audit' | head -12
echo
echo "=== finish-root.log ==="
cat /root/fuxi/finish-root.log 2>/dev/null | head -15
echo
echo "=== mkiosroot 相关的 dmg 名字 ==="
grep -rn 'OS.dmg\|SystemOS\|AppOS' /root/fuxi/*.log 2>/dev/null | head -5
