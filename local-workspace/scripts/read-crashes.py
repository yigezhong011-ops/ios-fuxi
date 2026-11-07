#!/usr/bin/env python3
"""Summarize the crash reports lifted from the Data area: exception, reason, faulting stack. Read-only."""
import json
import sys
from pathlib import Path

d = Path('/mnt/e/DSH-Fuxi/logs/crashes')
names = sys.argv[1:] or sorted(p.stem for p in d.glob('*.bin'))
for name in names:
    raw = (d / f'{name}.bin').read_bytes().split(b'\0')[0].decode(errors='replace')
    print('=====', name, len(raw))
    head, _, rest = raw.partition('\n')
    print(head[:260])
    dec = json.JSONDecoder()
    try:
        j, _ = dec.raw_decode(rest)
    except Exception as e:
        print('body not whole json:', e)
        for key in ('"exception"', '"termination"', '"asi"', '"ktriageinfo"'):
            at = rest.find(key)
            if at >= 0:
                print(rest[at:at + 420])
        continue
    for k in ('procPath', 'cpuType', 'exception', 'termination', 'vmRegionInfo', 'asi', 'ktriageinfo', 'lastExceptionBacktrace'):
        if k in j and k != 'lastExceptionBacktrace':
            print(k, str(j[k])[:900])
    imgs = j.get('usedImages', [])

    def show(frames, n=26):
        for f in frames[:n]:
            i = f.get('imageIndex', -1)
            im = imgs[i] if 0 <= i < len(imgs) else {}
            print('   ', im.get('name', '?')[:34].ljust(34), f.get('symbol', '?')[:90], '+%d' % f.get('symbolLocation', 0), hex(f.get('imageOffset', 0)))
    if j.get('lastExceptionBacktrace'):
        print('-- last exception backtrace')
        show(j['lastExceptionBacktrace'])
    ft = j.get('faultingThread')
    th = j.get('threads') or []
    if isinstance(ft, int) and ft < len(th):
        print('-- faulting thread', ft, th[ft].get('name', ''), th[ft].get('queue', ''))
        show(th[ft].get('frames', []))
