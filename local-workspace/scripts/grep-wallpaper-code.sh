#!/bin/bash
set -uo pipefail
R=/mnt/e/DSH-Fuxi/read
echo "=== 参考资料里提到 wallpaper 的文件 ==="
grep -rl -i 'wallpaper' "$R" 2>/dev/null | head -10
echo
echo "=== make-gpu-addon.py 里 wallpaper 的说明 ==="
grep -n -B2 -A6 'wallpaper' "$R/wallpaper/make-gpu-addon.py" 2>/dev/null | head -30 | cut -c1-165
echo
echo "=== 插件源码里的 wallpaper ==="
grep -n -i 'wallpaper' "$R/wallpaper/NativeAdrenoMetalPlugin.mm" 2>/dev/null | head -15 | cut -c1-165
