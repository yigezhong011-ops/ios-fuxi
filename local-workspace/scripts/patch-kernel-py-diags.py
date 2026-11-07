#!/usr/bin/env python3
"""The kernel driver hardcodes CCC_OVERRIDE_OPTIONS, so add the two diagnostics
that upstream clang escalates on XNU's macOS-only SETUP tools."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
old = "'CCC_OVERRIDE_OPTIONS': '# +-Wno-missing-designated-field-initializers +-Wno-unused-but-set-global'}"
new = ("'CCC_OVERRIDE_OPTIONS': '# +-Wno-missing-designated-field-initializers "
       "+-Wno-unused-but-set-global +-Wno-error=format +-Wno-error=implicit-function-declaration "
       "+-Wno-error=incompatible-pointer-types +-Wno-error=int-conversion'}")

if old not in t:
    if '-Wno-error=format' in t:
        print('已经包含所需诊断')
    else:
        raise SystemExit('找不到 CCC_OVERRIDE_OPTIONS 那一行')
else:
    p.write_text(t.replace(old, new))
    print('已更新 CCC_OVERRIDE_OPTIONS')

for line in p.read_text().splitlines():
    if 'CCC_OVERRIDE_OPTIONS' in line:
        print('  ' + line.strip()[:200])
