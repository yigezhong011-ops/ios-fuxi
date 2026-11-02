#!/usr/bin/env python3
"""Print one area of a UniXNU device record in full (read-only).
Usage: device-area.py <device> <area-id>"""
import pathlib
import sys
import tomllib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
dev, aid = sys.argv[1:3]
req = urllib.request.Request(
    f'https://api.github.com/repos/UniXNU/UniXNU/contents/docs/.vitepress/device-records/{dev}.toml?ref=main',
    headers={'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github.raw'})
rec = tomllib.loads(urllib.request.urlopen(req, timeout=120).read().decode())
print('repo:', rec.get('repository') or rec.get('device', {}))
for area in rec.get('area', []):
    if area.get('id') == aid:
        for k, v in area.items():
            if isinstance(v, list):
                print(f'{k}:')
                for s in v:
                    print('  -', s)
            else:
                print(f'{k}: {v}')
