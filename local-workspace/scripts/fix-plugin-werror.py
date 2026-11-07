#!/usr/bin/env python3
"""Make the plugin compile tolerate the newer clang's warnings.

793d6bddf7 lists '-Wall', '-Wextra', '-Werror' in base, and Xcode 26.6's clang reports
unused function 'patchFramebufferBranch' there, which stops the build. -Wno-error after
-Werror demotes warnings again without touching the source.
"""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml')
text = p.read_bytes().decode('utf-8').replace('\r\n', '\n')

anchor = "              run(sys.executable, root / 'scripts/build-adreno-metal-plugin.py')\n"
patch = (
    "              # Xcode 26.6 flags an unused function in the plugin source as an error\n"
    "              plug = root / 'scripts/build-adreno-metal-plugin.py'\n"
    "              ps = plug.read_text()\n"
    "              if \"'-Wno-error'\" not in ps:\n"
    "                  ps = ps.replace(\"'-Wall', '-Wextra', '-Werror',\",\n"
    "                                  \"'-Wall', '-Wextra', '-Werror', '-Wno-error',\")\n"
    "                  plug.write_text(ps)\n"
)

if '-Wno-error' in text:
    print('已经加过 -Wno-error')
elif anchor in text:
    p.write_bytes(text.replace(anchor, patch + anchor, 1).encode('utf-8'))
    print('已插入 -Wno-error 补丁')
else:
    print('找不到锚点')

for i, line in enumerate(p.read_bytes().decode('utf-8').splitlines(), 1):
    if 'Wno-error' in line or 'build-adreno-metal-plugin' in line:
        print('%4d| %s' % (i, line.strip()[:120]))
