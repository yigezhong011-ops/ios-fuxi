#!/usr/bin/env python3
"""Find the boot arguments the working kernel parses for touch and backlight."""
import re
from pathlib import Path

data = Path('/tmp/working-kernel.macho').read_bytes()
print('内核 %d 字节' % len(data))

strings = re.findall(rb'[ -~]{4,80}', data)
print('字符串 %d 条' % len(strings))

want = re.compile(rb'(touch|backlight|brightness|panel|keys|battery)', re.I)
hits = []
for s in strings:
    if want.search(s) and (b'=' in s or b'-' in s) and len(s) < 60:
        text = s.decode('ascii', 'replace')
        if re.fullmatch(r'[a-z0-9=_-]+', text):
            hits.append(text)
print('候选参数名:')
for text in sorted(set(hits))[:40]:
    print('   ', text)
