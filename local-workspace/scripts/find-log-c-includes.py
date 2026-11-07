#!/usr/bin/env python3
"""Find the compile command for libkern/os/log.c and its include paths."""
import re
import zipfile

with zipfile.ZipFile('/root/art-format2-logs.zip') as z:
    text = z.read('kernel-bootstrap.log').decode('utf-8', 'replace')

pos = text.find('libkern/os/log.c')
print('第一次出现位置', pos)
chunk = text[max(0, pos - 3000):pos + 200]
incs = re.findall(r'-I\s*(\S+)', chunk)
print('该片段里的 -I:')
for inc in incs[-12:]:
    print('   ', inc[:150])
print()
print('片段尾部:')
print(chunk[-600:].replace('\n', ' ')[:600])
