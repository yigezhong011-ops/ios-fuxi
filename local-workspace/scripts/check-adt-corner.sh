#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/tools/mkadt-fuxi.py
echo "=== ADT 里和圆角/屏幕几何相关的属性 ==="
grep -n -i 'corner\|radius\|bounding\|scale\|display\|width\|height' "$F" | head -25
