#!/usr/bin/env python3
"""Blocks new since an older lscan: what changed in the log, boot by boot. Read-only. Usage: read-auto200p.py <old lscan> <new lscan> <out new.txt>"""
import hashlib
import re
import sys
from collections import Counter

old, new, out = sys.argv[1:4]


def blocks(path):
    b = open(path, 'rb').read()
    marks = [m for m in re.finditer(rb'(?m)^#C (\d+) (\d+)\n', b)]
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(b)
        yield int(m.group(1)), b[m.end():end]


seen = {hashlib.sha1(c).digest() for _, c in blocks(old)}
fresh = [(o, c) for o, c in blocks(new) if hashlib.sha1(c).digest() not in seen]
fresh.sort()
text = b''.join(c for _, c in fresh).decode('latin1')
open(out, 'w', encoding='latin1').write(text)
print('new blocks', len(fresh), 'bytes', len(text))
print('boot-args seen in new blocks:')
for k, v in Counter(re.findall(r'sheng-autoreset=\d+|boot-ui-focus4=\w+', text)).most_common():
    print('  ', v, k)
print('launchd boot-args lines', len(re.findall(r'<Notice>: boot-args = ', text)))
for pat in ('generalErrorDomain', 'Data store could not be created', 'NSLocalizedFailureReason=<private>',
            'CMPhotoCompressionSessionAddImage', 'unableToFinalizeImageDestination', 'Kicking off 61',
            'failed to setup database', 'could not setup data store', 'could not validate data store',
            'Data store migration finished', 'Data store migration initiated', 'Data store migration not needed',
            'AGXDeviceUserClient failed MACF', 'chronod', 'WidgetRenderer', 'Terminating', 'jetsam'):
    print(f'{text.count(pat):8d}  {pat}')
print('private overall', text.count('<private>'))
print('poster lines with <private>', sum(1 for l in text.split('\n') if '<private>' in l and re.search(r'(?i)poster', l)))
print('== HEVC/codec messages')
for k, v in Counter(re.sub(r'\d+', '#', l)[:170] for l in text.split('\n') if re.search(r'codec |hvc1|CMPhoto|ImageDestination', l)).most_common(14):
    print(f'{v:6d}  {k}')
print('== generalErrorDomain, with reason')
for k, v in Counter(re.findall(r'generalErrorDomain Code=\d+ [^\n]{0,180}', text)).most_common(8):
    print(f'{v:6d}  {k}')
print('== poster messages, first of each')
rx = re.compile(r'(?i)migrat|data ?store|descriptor|gallery|PRB|PBF|poster')
skip = re.compile(r'RBS|RBAssertion|osservice<|caching|coredatastore')
keys = Counter()
for l in text.split('\n'):
    if rx.search(l) and not skip.search(l):
        k = re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}|\d+', '#', l)[:150]
        if keys[k] == 0 and len(keys) < 90:
            print('   ', l[:230])
        keys[k] += 1
