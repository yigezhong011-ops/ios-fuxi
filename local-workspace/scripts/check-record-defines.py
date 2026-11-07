#!/usr/bin/env python3
"""Check whether the XNU compile record carries the boot-progress define."""
import json
from pathlib import Path

rec = Path('/root/ux2/fuxi/tree/build/xnu/ios-obj/DEVELOPMENT_ARM64_BCM2837/bsd/DEVELOPMENT/kern_exec.o.json')
if not rec.is_file():
    print('没有记录:', rec)
else:
    d = json.loads(rec.read_text().strip().rstrip(','))
    args = d['arguments']
    print('参数总数:', len(args))
    print('含 XNU_BOOT_PROGRESS:', any('XNU_BOOT_PROGRESS' in a for a in args))
    print('前 12 个 -D:')
    for a in [x for x in args if x.startswith('-D')][:12]:
        print('   ', a)
