#!/usr/bin/env python3
"""Third pass: dates of the key errors, and their context. Read-only. Usage: read-lscan3.py <lscan.txt>"""
import bisect
import re
import sys
from collections import Counter

text = open(sys.argv[1], 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
starts = [m.start() for m in re.finditer(r'(?m)^#C ', text)]
DATE = re.compile(r'20\d\d-\d\d-\d\d[ T]\d\d:\d\d')
stamps = {}
for m in DATE.finditer(text):
    i = bisect.bisect_right(starts, m.start()) - 1
    v = m.group()[:16].replace('T', ' ')
    if v > stamps.get(i, ''):
        stamps[i] = v
print('chunks with a date', len(stamps), 'of', len(starts))
print('by day', sorted(Counter(v[:10] for v in stamps.values()).items())[-12:])


def when(pos):
    i = bisect.bisect_right(starts, pos) - 1
    return stamps.get(i, '?')


def dates(title, pat, top=6, width=300):
    rx = re.compile(pat)
    hours, msgs = Counter(), Counter()
    for m in rx.finditer(text):
        ls = text.rfind('\n', 0, m.start()) + 1
        le = text.find('\n', m.end())
        hours[when(m.start())[:13]] += 1
        msgs[text[ls:le][:width]] += 1
    print(f'== {title}: {sum(msgs.values())} hits, {len(msgs)} distinct')
    print('   when', sorted(hours.items())[-10:])
    for k, v in msgs.most_common(top):
        print(f'{v:5d} {k}')


def context(title, pat, before=12, after=12, limit=3, width=260):
    print(f'== context: {title}')
    shown = 0
    seen = set()
    for m in re.finditer(pat, text):
        ls = text.rfind('\n', 0, m.start()) + 1
        le = text.find('\n', m.end())
        key = text[ls:le][:60]
        if key in seen and shown:
            continue
        seen.add(key)
        a = ls
        for _ in range(before):
            a = text.rfind('\n', 0, a - 1) + 1
        b = le
        for _ in range(after):
            b = text.find('\n', b + 1)
        print(f'  [{when(m.start())}]')
        for x in text[a:b].split('\n'):
            print('   ', x[:width])
        print('    ---')
        shown += 1
        if shown >= limit:
            break


dates('data store failure', r'Data store could not be created|Unable to setup dataStore|Datastore could not be loaded')
dates('picker and poster assert', r'dataStore != nil|Invalid parameter not satisfying|bs_assert|NSInternalInconsistency[^\n]*Poster')
dates('hvc1 encode', r'CMPhotoCompressionSessionAddImage')
dates('finalize', r'unableToFinalizeImageDestination')
dates('codec words', r'hvc1|HEIF|HEIC|kVT[A-Z]|VTCompression|VTDecompression|AppleAVD|AppleAVE|H\.?264|HEVC', 25, 220)
dates('extension not found', r'extensionNotFound\(com\.apple\.weather')
dates('unknown extension', r'Unknown extension process')
dates('reload failed', r'Reload failed')
dates('poster shaders', r'pro24MainFragment|lightsMeshFragment')
dates('function constant', r'NeedsInput\(FunctionConstant')
dates('nil compute', r'computeFunction must not be nil')
dates('device refused', r'native-metal: device refused')
dates('oom texture', r'refused: texture: OutOfMemory')
context('data store failure', r'Data store could not be created', 25, 12, 2)
context('hvc1 encode', r'CMPhotoCompressionSessionAddImage', 8, 10, 2)
context('finalize', r'unableToFinalizeImageDestination', 8, 8, 2)
context('poster shader', r'frag (pro24MainFragment|lightsMeshFragment)', 10, 6, 2)
context('nil compute', r'computeFunction must not be nil', 10, 6, 1)
