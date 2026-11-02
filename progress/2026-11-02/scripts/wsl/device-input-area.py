#!/usr/bin/env python3
"""Print the button-related sentences of a UniXNU device record (read-only).
Usage: device-input-area.py <device>..."""
import pathlib
import re
import sys
import tomllib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
RX = re.compile(r'button|volume|power key|pwrkey|lock button|resin|gpio-keys|consumer', re.I)
for dev in sys.argv[1:]:
    req = urllib.request.Request(
        f'https://api.github.com/repos/UniXNU/UniXNU/contents/docs/.vitepress/device-records/{dev}.toml?ref=main',
        headers={'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github.raw'})
    try:
        rec = tomllib.loads(urllib.request.urlopen(req, timeout=120).read().decode())
    except Exception as e:
        print(f'== {dev}: {e}')
        continue
    print(f'== {dev}')
    for area in rec.get('area', []):
        for key, val in area.items():
            for s in (val if isinstance(val, list) else [val]):
                if isinstance(s, str):
                    for part in re.split(r'(?<=\.)\s+', s):
                        if RX.search(part):
                            print(f"  [{area.get('id')}/{area.get('status')}/{key}] {part[:400]}")
