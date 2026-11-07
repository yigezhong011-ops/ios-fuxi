#!/usr/bin/env python3
"""Find the docs for skip_setup and trust cache in the payload configuration."""
import re
import subprocess

pages = ['/zh/reference/boot-configuration', '/zh/porting/steps', '/zh/porting/device-repository',
         '/zh/porting/dual-system-partition', '/zh/porting/ufs']
for p in pages:
    html = subprocess.run(['curl', '-sL', '--max-time', '60', 'https://unixnu.com' + p],
                          capture_output=True, text=True, encoding='utf-8', errors='replace').stdout
    text = re.sub(r'(?s)<script.*?</script>', '', html)
    text = re.sub(r'(?s)<style.*?</style>', '', text)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    for kw in ('skip_setup', 'skip-setup', 'trust_cache', 'trustcache', '信任缓存'):
        for m in re.finditer(kw, text):
            s = max(0, m.start() - 200)
            print('==', p, kw)
            print('   ', text[s:m.start() + 320].strip()[:420])
            break
