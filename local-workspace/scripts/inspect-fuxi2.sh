#!/bin/bash
# Clone the format-2 fuxi device repo and inspect what it carries.
set -euo pipefail
W=/root/fuxi/fuxi2
rm -rf "$W"
git clone -q --depth 1 https://github.com/Star-mailaz/fuxi-ios16-device.git "$W"
cd "$W"
echo "=== 顶层 ==="
ls
echo
echo "=== scripts ==="
ls scripts | head -20
echo
echo "=== 有没有 DISPLAY-ABI / stub ==="
ls scripts | grep -i 'display-abi\|fuxi-stub\|check-display' || echo "  没有"
echo
echo "=== configs ==="
ls configs
echo
echo "=== workflow ==="
ls .github/workflows/ 2>/dev/null || echo "  没有 workflow"
echo
echo "=== patches/xnu/series 前 12 行 ==="
head -12 patches/xnu/series 2>/dev/null | cut -c1-140
