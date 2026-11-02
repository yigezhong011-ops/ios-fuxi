#!/bin/bash
# How other UniXNU ports got the wallpaper drawn (docs, device records, code search; read-only)
python3 /root/fuxi/cs.py 'wallpaper org:UniXNU' | head -25
sleep 3
python3 /root/fuxi/cs.py 'wallpaper black SpringBoard UniXNU' | head -25
sleep 3
python3 /root/fuxi/cs.py 'PosterBoard UniXNU' | head -20
echo "== device records mentioning wallpaper"
python3 - <<'EOF'
import json, pathlib, re, tomllib, urllib.request
TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
lst = json.loads(urllib.request.urlopen(urllib.request.Request(
    'https://api.github.com/repos/UniXNU/UniXNU/contents/docs/.vitepress/device-records?ref=main', headers=H), timeout=120).read())
rx = re.compile(r'wallpaper|PosterBoard|backdrop', re.I)
for e in lst:
    if not e['name'].endswith('.toml'):
        continue
    raw = urllib.request.urlopen(urllib.request.Request(e['download_url'], headers={'User-Agent': 'dsh'}), timeout=120).read().decode()
    for part in re.split(r'(?<=[.!?])\s+|\n', raw):
        if rx.search(part):
            print(f"[{e['name']}] {part.strip()[:500]}")
EOF
