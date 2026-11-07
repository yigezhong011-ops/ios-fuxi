#!/bin/bash
# Upstream's own records on the wallpaper and GPU client lists. Read-only.
U=/root/fuxi/src-unixnu; A=/root/fuxi/src-adreno740; M=/root/fuxi/src-adrenometal
git -C $U show origin/main:docs/.vitepress/device-records/alioth.toml > /tmp/alioth.toml
git -C $U show origin/main:docs/.vitepress/device-records/fuxi.toml > /tmp/fuxi.toml
git -C $U show origin/main:docs/.vitepress/device-records/asteroids.toml > /tmp/asteroids.toml
echo "== alioth wallpaper lines"
grep -n -E 'Poster|wallpaper|Wallpaper|widget|Widget' /tmp/alioth.toml | cut -c1-1500 | head -24
echo "== fuxi record, wallpaper and widget"
grep -n -E 'Poster|wallpaper|Wallpaper|widget|Widget' /tmp/fuxi.toml | cut -c1-1100 | head -12
echo "== asteroids rtc"
sed -n '160,172p' /tmp/asteroids.toml | cut -c1-800
echo "== allow-list in our tree"
grep -n -E 'PosterBoard|AegirPoster|KaleidoscopePoster|CollectionsPoster|Poster' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/patches/xnu/*.patch | cut -c1-190 | head -20
echo "== allow-list at upstream head"
git -C $U grep -n -E 'AegirPoster|CollectionsPoster|KaleidoscopePoster' origin/main -- patches kits tools 2>/dev/null | sed 's/^origin\/main://' | cut -c1-190 | head -14
echo "== at our pin"
git -C $U grep -n -E 'AegirPoster|CollectionsPoster|KaleidoscopePoster' 793d6bddf7 -- patches kits tools 2>/dev/null | sed 's/^793d6bddf7://' | cut -c1-190 | head -14
echo "== poster process names in our log"
python3 -I - <<'EOF'
import re
from collections import Counter
t = open('/mnt/e/DSH-Fuxi/logs/carve-tonight/lscan.txt', 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
print(Counter(re.findall(r'com\.apple\.[A-Za-z.]*(?:Poster|poster)[A-Za-z.]*', t)).most_common(16))
print(Counter(re.findall(r'\b[A-Z][A-Za-z]+Poster\w*\(\d+\)', t)).most_common(16))
print(Counter(re.sub(r'\d+', '#', x) for x in re.findall(r'Sandbox: \w*Poster\w*\(\d+\) deny\(1\) [^\n]{0,70}', t)).most_common(12))
EOF
tr -d '\000' < /root/fuxi/log-oslog1/*/msgbuf.txt | grep -a -E 'Poster' | sed -E 's/^\[[ 0-9.]+\]:? *//; s/[0-9]+/#/g' | cut -c1-120 | sort | uniq -c | sort -rn | head -14
