#!/usr/bin/env python3
"""Relax warnings for the host SETUP tools: their format strings differ on Linux."""
from pathlib import Path

p = Path('/opt/unixnu-linux/CommandLineTools/usr/bin/clang')
t = p.read_text()
needle = 'exec /usr/bin/clang "${args[@]}"'
if '-Wno-error' in t:
    print('已经包含 -Wno-error')
else:
    if needle not in t:
        raise SystemExit('找不到 host 分支')
    t = t.replace(needle, 'exec /usr/bin/clang -Wno-error -Wno-format "${args[@]}"')
    p.write_text(t)
    print('已加上 -Wno-error -Wno-format')

print('--- 现在 host 分支 ---')
for line in p.read_text().splitlines():
    if 'usr/bin/clang' in line:
        print('  ' + line.strip())
