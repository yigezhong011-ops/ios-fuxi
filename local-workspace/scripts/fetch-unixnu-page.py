#!/usr/bin/env python3
"""Pull the content out of a unixnu.com device page (the nav is huge)."""
import re
import subprocess
import sys

url = sys.argv[1]
html = subprocess.run(['curl', '-sL', '--max-time', '60', url], capture_output=True, text=True,
                      encoding='utf-8', errors='replace').stdout
# the content sits in <main> or after the sidebar; strip scripts/styles first
body = re.sub(r'(?s)<script.*?</script>', '', html)
body = re.sub(r'(?s)<style.*?</style>', '', body)
m = re.search(r'(?s)<main.*?</main>', body)
if not m:
    m = re.search(r'(?s)<article.*?</article>', body)
frag = m.group(0) if m else body
text = re.sub(r'(?s)<(h[1-6])[^>]*>', r'\n## ', frag)
text = re.sub(r'(?s)</(p|div|li|tr|h[1-6])>', '\n', text)
text = re.sub(r'<[^>]+>', ' ', text)
text = re.sub(r'[ \t]+', ' ', text)
lines = [l.strip() for l in text.split('\n')]
out = []
for l in lines:
    if l and l not in out[-3:]:
        out.append(l)
print('\n'.join(out)[:6000])
