#!/usr/bin/env python3
"""CCC_OVERRIDE_OPTIONS starts with '#', which clang treats as "stop here", so
every override after it was ignored (including the ones this build needs)."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
old = "'CCC_OVERRIDE_OPTIONS': '# +-Wno-missing-designated-field-initializers"
new = "'CCC_OVERRIDE_OPTIONS': '+-Wno-missing-designated-field-initializers"
if new in t:
    print('已经去掉 #')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('已去掉开头的 #')
else:
    raise SystemExit('找不到该设置')

for line in p.read_text().splitlines():
    if 'CCC_OVERRIDE_OPTIONS' in line and 'Wno-missing' in line:
        print('  ' + line.strip()[:240])
