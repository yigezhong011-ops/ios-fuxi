#!/usr/bin/env python3
"""Which boot wrote this window and how far did it go? Compare with earlier hang and daily logs. Read-only."""
import re
import subprocess
import sys
from pathlib import Path

DEC = '/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py'
K = re.compile(r'staged|Staged', re.I)
for name in sys.argv[1:]:
    b = Path(f'/mnt/e/DSH-Fuxi/logs/twrp-{name}.bin')
    o = Path(f'/root/fuxi/log-{name}')
    subprocess.run(['rm', '-rf', str(o)])
    subprocess.run(['python3', '-I', DEC, '--decode', str(b), '--out', str(o)], capture_output=True)
    d = next(o.glob('*/'))
    h = dict(x.split('=', 1) for x in (d / 'header.txt').read_text().splitlines() if '=' in x)
    print('=====', name, 'boot', h.get('boot_id'), 'uptime', h.get('uptime_s'), 'slots', h.get('slots_written'), 'state', h.get('state'))
    s = (d / 'latest.txt').read_text(errors='replace')
    for line in s.splitlines():
        if K.search(line) or re.match(r'(#slot|X[0-9] |W[01] |S c|\[metal askers|\[gpu clients|\[coherence|D st)', line):
            print('  ', line[:190])
    msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
    print('  msgbuf chars', len(msg))
    stamps = re.findall(r'\[ *([\d.]+)\]', msg)
    print('  first/last stamp', stamps[:1], stamps[-1:])
    args = re.search(r'[ -~]{0,60}sheng-staged-apps[ -~]{0,60}', msg)
    print('  arg in msgbuf:', args[0] if args else None)
    for m in list(re.finditer(r'[ -~]{0,90}(?:staged|launchd\[1\]|panic\(|Panic|mount|data volume|owner data)[ -~]{0,110}', msg, re.I))[-14:]:
        print('    ', m[0][:200])
    print('  tail:', msg[-900:].replace('\n', ' | '))
    text = (d / 'slots.txt').read_text(errors='replace')
    rows = re.findall(r'^.*staged.*$', text, re.M | re.I)
    print('  staged rows', len(rows), rows[:2], rows[-2:])
