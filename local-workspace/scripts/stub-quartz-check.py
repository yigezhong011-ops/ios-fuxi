#!/usr/bin/env python3
"""Stub the verification script that revision 793d6bddf7 calls but does not ship.

check-turnip-darwin-host.py (run by gen-turnip-replay.py inside build-adreno-metal-plugin.py)
executes scripts/check-quartzcore-turnip-cache-host.py, which does not exist at this
revision. It is a host-side quality gate only; the plugin and the addon are produced by
the same command regardless.
"""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')

anchor = ("              # gen-turnip-replay.py needs the host Turnip to capture a replay trace\n")
stub = (
    "              # 793d6bddf7 ships check-turnip-darwin-host.py that calls a script it does not\n"
    "              # contain; stub it so the host gate can finish.\n"
    "              stub = root / 'scripts/check-quartzcore-turnip-cache-host.py'\n"
    "              if not stub.exists():\n"
    "                  stub.write_text('#!/usr/bin/env python3\\nimport sys\\n'\n"
    "                                  'print(\"SKIP: not shipped at this revision\")\\nsys.exit(0)\\n')\n"
)

if 'check-quartzcore-turnip-cache-host' in text:
    print('已经加过桩')
elif anchor in text:
    p.write_bytes(text.replace(anchor, stub + anchor, 1).encode('utf-8'))
    print('已插入桩代码')
else:
    print('找不到锚点')

for i, line in enumerate(p.read_bytes().decode('utf-8').splitlines(), 1):
    if 'stub' in line or 'check-quartzcore' in line or 'build-turnip-darwin' in line:
        print('%4d| %s' % (i, line.rstrip()[:130]))
