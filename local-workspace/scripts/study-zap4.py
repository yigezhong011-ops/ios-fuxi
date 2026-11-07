#!/usr/bin/env python3
# Read-only: list each boot's slot log with its last time and last rows, so hang boots stand out from normal ones.
import glob, os, re, sys
seen = {}
for f in glob.glob('/root/fuxi/**/slots.txt', recursive=True) + glob.glob('/mnt/e/DSH-Fuxi/logs/**/slots.txt', recursive=True):
    try:
        t = open(f, 'rb').read().decode('latin1')
    except OSError:
        continue
    parts = re.split(r'(?m)^#slot (\d+) t=(\d+)s tag=.*$', t)
    if len(parts) < 4:
        continue
    slots = [(int(parts[i + 1]), parts[i + 2]) for i in range(1, len(parts) - 2, 3)]
    ts = [s[0] for s in slots]
    key = hash(t)
    if key in seen:
        continue
    seen[key] = f
    last = slots[-1][1] if ts else ''
    last = max(slots, key=lambda s: s[0])[1]
    rows = {m.group(1): m.group(2)[:44] for m in re.finditer(r'(?m)^X(\d) ?(.*)$', last)}
    print(f"{max(ts):5d}s n{len(ts):4d} {f.replace('/root/fuxi/', '')[:52]:52s} X2={rows.get('2','')} | X6={rows.get('6','')} | X7={rows.get('7','')}")
