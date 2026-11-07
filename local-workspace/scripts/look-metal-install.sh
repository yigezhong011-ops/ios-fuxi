#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== FuxiMetal.bundle 安装路径 ==="
grep -rn 'FuxiMetal.bundle' docs docs-lanes tools/*.sh tools/*.py 2>/dev/null | grep -iE 'install|cp |/System|/usr|path' | head -12
echo
echo "=== libmetal2vulkan 安装路径 ==="
grep -rn 'libmetal2vulkan' docs docs-lanes tools/*.sh 2>/dev/null | grep -iE 'install|cp |/usr|/System' | head -12
echo
echo "=== metal-clients.conf 用途 ==="
grep -rn 'metal-clients.conf' docs docs-lanes tools/*.sh 2>/dev/null | head -6
