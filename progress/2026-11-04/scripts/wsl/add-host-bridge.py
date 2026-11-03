#!/usr/bin/env python3
"""Build the native bridge for the host too: check-priming-cache-host.py links
build/adreno-metal-bridge/host/libadreno_metal_bridge.a."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')

anchor = "              run(sys.executable, root / 'scripts/build-adreno-metal-plugin.py')\n"
add = ("              # the host self-tests link the host bridge library\n"
       "              run(sys.executable, root / 'scripts/build-adreno-metal-bridge.py', '--target', 'host')\n")

if "'--target', 'host')\n" in text and 'build-adreno-metal-bridge.py' in text:
    print('已经加过 host bridge')
elif anchor in text:
    p.write_bytes(text.replace(anchor, add + anchor, 1).encode('utf-8'))
    print('已插入 host bridge 构建')
else:
    print('找不到锚点')

for i, line in enumerate(p.read_bytes().decode('utf-8').splitlines(), 1):
    if 'build-adreno-metal-bridge' in line or 'build-adreno-metal-plugin' in line or 'build-turnip-darwin' in line:
        print('%4d| %s' % (i, line.strip()[:120]))
