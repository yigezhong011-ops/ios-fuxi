#!/usr/bin/env python3
"""Is the firehose header generated at all?"""
import re
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    text = z.read('kernel-bootstrap.log').decode('utf-8', 'replace')

hits = [m.start() for m in re.finditer(r'firehose_buffer_private', text)]
print('提到 firehose_buffer_private 的次数', len(hits))
for pos in hits[:6]:
    print('   ', text[max(0, pos - 200):pos + 80].replace('\n', ' ')[-260:])
