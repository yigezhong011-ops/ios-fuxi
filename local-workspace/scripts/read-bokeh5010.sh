#!/bin/bash
# Read-only: the default wallpaper's dark and light background colours; the renderer's environment; WSL working space.
cd /root/fuxi/t50-gpu-wall/root/Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/5010.Multicolored.wallpaper || exit 1
python3 -I - <<'PY'
import plistlib
d = plistlib.load(open('Wallpaper.plist', 'rb'))
print({k: v for k, v in d.items() if k != 'assets'})
for role, v in d['assets'].items():
    for style, s in v.items():
        print(role, style, 'bg', s.get('backgroundColors'), 'count', s.get('bubbleCount'), 'bubbles', s.get('bubbleColors', [])[:3])
PY
grep -a -m2 -o -E '<PRRenderer: [ -~]{0,700}' /mnt/e/DSH-Fuxi/logs/carve-wallcat/lscan.txt | cut -c1-720
echo '== /root/fuxi'
du -sh /root/fuxi 2>/dev/null
du -s /root/fuxi/* 2>/dev/null | sort -rn | head -14 | awk '{printf "%6.1f GB %s\n",$1/1048576,$2}'
ls -d /root/fuxi/auto-* /root/fuxi/t50-* 2>/dev/null | wc -l
du -sc /root/fuxi/auto-* /root/fuxi/t50-* 2>/dev/null | tail -1 | awk '{printf "auto and t50 dirs %.1f GB\n",$1/1048576}'
