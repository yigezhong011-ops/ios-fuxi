#!/bin/bash
set -uo pipefail
echo "=== 格式表 / 550 ==="
grep -rn 'pixelFormat\|550\|formats\[\]\|FormatSupport' /root/ios-fuxi/tools/fuxi-metal/*.hpp /root/ios-fuxi/tools/fuxi-metal/*.cpp 2>/dev/null | grep -i '550\|format' | head -20
echo
echo "=== 支持格式列表 ==="
grep -rln 'RGBA8Unorm\|pixelFormats' /root/ios-fuxi/tools/fuxi-metal/ 2>/dev/null | head -5
