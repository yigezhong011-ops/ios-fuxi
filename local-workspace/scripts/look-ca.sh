#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== CoreAnimation / 软件渲染 相关 ==="
grep -rn -i -E 'coreanimation|software.*render|CAForce|CALayer.*software' tools/*.py tools/*.sh docs/*.md docs-lanes/*.md 2>/dev/null | head -15 || echo "(none)"
echo
echo "=== 镜像里是否已有 CoreAnimation 偏好 ==="
ls -la /root/fuxi/mnt/wall/private/var/mobile/Library/Preferences/ 2>/dev/null | head -20 || echo "(mount not present)"
