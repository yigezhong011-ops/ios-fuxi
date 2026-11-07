#!/usr/bin/env python3
"""IOUserServer.cpp defines the two service-property methods unconditionally, but
their declarations sit behind `#if PRIVATE_WIFI_ONLY`. Apple's kernel build sets
it; ours does not, so define it for every clang invocation."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/kernel.py')
t = p.read_text()
if 'PRIVATE_WIFI_ONLY' in t:
    print('已经加过')
else:
    old = "+-Wno-error=int-conversion'}"
    new = "+-Wno-error=int-conversion +-DPRIVATE_WIFI_ONLY=1'}"
    if old not in t:
        raise SystemExit('找不到 CCC_OVERRIDE_OPTIONS 的结尾')
    p.write_text(t.replace(old, new, 1))
    print('已加入 -DPRIVATE_WIFI_ONLY=1')

for line in p.read_text().splitlines():
    if 'CCC_OVERRIDE_OPTIONS' in line and 'PRIVATE_WIFI' in line:
        print('  ' + line.strip()[:220])
