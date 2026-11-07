#!/usr/bin/env python3
"""List the links on the log-capture page, looking for the entry-probe page."""
import re
import subprocess

html = subprocess.run(['curl', '-sL', '--max-time', '60', 'https://unixnu.com/zh/porting/log-capture'],
                      capture_output=True, text=True, encoding='utf-8', errors='replace').stdout
links = sorted(set(re.findall(r'href="(/zh/[^"#]*)"', html)))
for l in links:
    print(l)
