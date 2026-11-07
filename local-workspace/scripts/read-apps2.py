#!/usr/bin/env python3
"""Did the staged copy finish, and did anything try to install the apps? Read-only."""
import re
import subprocess
from collections import Counter
from pathlib import Path

DEC = '/mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py'
o = Path('/root/fuxi/log-apps2')
subprocess.run(['rm', '-rf', str(o)])
subprocess.run(['python3', '-I', DEC, '--decode', '/mnt/e/DSH-Fuxi/logs/twrp-apps2.bin', '--out', str(o)], capture_output=True)
d = next(o.glob('*/'))
h = dict(x.split('=', 1) for x in (d / 'header.txt').read_text().splitlines() if '=' in x)
print('boot', h.get('boot_id'), 'uptime', h.get('uptime_s'), 'slots', h.get('slots_written'))
text = (d / 'slots.txt').read_text(errors='replace')
slots = [x for x in re.split(r'(?m)^(?=#slot )', text) if x.startswith('#slot')]
last = slots[-1] if slots else ''
for line in last.splitlines():
    if re.match(r'(\[coherence|\[gpu clients|\[metal askers|G commit|PR |D st)', line):
        print(' ', line[:200])
print('staged rows in slots:', Counter(re.sub(r'\d+', '#', x)[:120] for x in re.findall(r'^.*(?:staged|Staged|SA ).*$', text, re.M)).most_common(6))
msg = (d / 'msgbuf.txt').read_text(errors='replace').replace('\0', '')
for pat in (r'staged', r'SystemAppMigrator|DataMigrat|migrationd|MigrationPlugin|DataMigration', r'installcoordinationd|installd|mobile_installation', r'Weather|com\.apple\.Health|Fitness\.app'):
    hits = re.findall(r'[ -~]{0,70}(?:%s)[ -~]{0,120}' % pat, msg)
    print('--', pat, len(hits))
    for k, v in Counter(re.sub(r'\[ *[\d.]+\]:|[0-9A-F]{8}-[0-9A-F-]{27}', '', x)[:190] for x in hits).most_common(6):
        print('  ', v, k)
