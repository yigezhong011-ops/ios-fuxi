#!/usr/bin/env python3
"""Search the uniXNU docs for the entry-probe / green-bar instructions."""
import re
import subprocess

pages = ['/zh/porting/platform', '/zh/porting/steps', '/zh/xnu/source-and-patches',
         '/zh/reference/boot-configuration', '/zh/porting/uefi-firmware', '/zh/reference/troubleshooting']

for p in pages:
    url = 'https://unixnu.com' + p
    html = subprocess.run(['curl', '-sL', '--max-time', '60', url], capture_output=True, text=True,
                          encoding='utf-8', errors='replace').stdout
    text = re.sub(r'(?s)<script.*?</script>', '', html)
    text = re.sub(r'(?s)<style.*?</style>', '', text)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    hits = [m.start() for m in re.finditer(r'绿条|入口探针|green bar|entry probe', text)]
    if hits:
        print('==', p, 'hits', len(hits))
        for h in hits[:4]:
            print('   ...', text[max(0, h - 160):h + 240].strip()[:380])
