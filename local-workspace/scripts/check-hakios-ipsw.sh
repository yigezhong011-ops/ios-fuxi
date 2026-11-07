#!/bin/bash
set -uo pipefail
cd /root/hakios-xnu-kernel || exit 1
echo "=== 文档里提到的 IPSW / 16.5 ==="
grep -rn '16\.5\|IPSW' docs/getting-started/*.md 2>/dev/null | head -12 | cut -c1-170
echo
echo "=== unpack.sh 期望什么 ==="
head -30 sysimage/unpack.sh 2>/dev/null | cut -c1-150
echo
echo "=== 设备/芯片层里有没有 IPSW 地址 ==="
grep -rn 'updates.cdn-apple\|Restore.ipsw' --include='*.md' --include='*.sh' --include='*.conf' . 2>/dev/null | head -6 | cut -c1-170
