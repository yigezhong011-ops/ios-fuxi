#!/usr/bin/env python3
"""Find the green-bar diagnostics page on unixnu.com."""
import re
import subprocess

for url in ('https://unixnu.com/zh/porting/bring-up', 'https://unixnu.com/zh/porting'):
    html = subprocess.run(['curl', '-sL', '--max-time', '60', url], capture_output=True, text=True,
                          encoding='utf-8', errors='replace').stdout
    links = sorted(set(re.findall(r'href="(/zh/[^"#]*)"', html)))
    print('==', url, len(links), 'links')
    for l in links:
        if any(k in l for k in ('diagn', 'green', 'bar', 'trouble', 'log', 'validate', 'boot')):
            print('   ', l)
