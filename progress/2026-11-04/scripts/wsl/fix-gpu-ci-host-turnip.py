#!/usr/bin/env python3
"""Add the host Turnip build to the GPU workflow (gen-turnip-replay.py requires it)."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
raw = p.read_bytes().decode('utf-8')
crlf = '\r\n' in raw
text = raw.replace('\r\n', '\n')

old = "run(sys.executable, root / 'scripts/build-turnip-darwin.py', '--target', 'ios')\n"
new = ("# gen-turnip-replay.py needs the host Turnip to capture a replay trace\n"
       "              run(sys.executable, root / 'scripts/build-turnip-darwin.py', '--target', 'host')\n"
       "              run(sys.executable, root / 'scripts/build-turnip-darwin.py', '--target', 'ios')\n")

if "'--target', 'host'" in text:
    print('已经补过 host 目标')
elif old in text:
    text = text.replace(old, '              ' + new if not old.startswith('              ') else new, 1)
    p.write_bytes(text.replace('\n', '\r\n' if crlf else '\n').encode('utf-8'))
    print('已插入 host Turnip 构建（原文件 CRLF=%s）' % crlf)
else:
    print('找不到锚点')

for i, line in enumerate(p.read_bytes().decode('utf-8').replace('\r\n', '\n').splitlines(), 1):
    if 'build-turnip-darwin' in line or 'build-adreno-metal-plugin' in line:
        print('%4d| %s' % (i, line.strip()[:120]))
