#!/usr/bin/env python3
"""How is fuxi_usbdbg_phase surfaced, and what does the XNU patch do?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'ljhhkx529/unixnu-fuxi'
REF = 'old'


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception:
        return {}


def raw(path):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{REF}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


tree = api(f'https://api.github.com/repos/{REPO}/git/trees/{REF}?recursive=1')
files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
print('=== 提到 fuxi_usbdbg_phase 的文件 ===')
for f in files:
    if not f.endswith(('.c', '.cpp', '.h', '.py', '.patch', '.md', '.sh')):
        continue
    text = raw(f)
    if 'fuxi_usbdbg_phase' in text or 'fuxi_usbdbg' in text:
        print('  ', f)
        for i, line in enumerate(text.splitlines(), 1):
            if 'fuxi_usbdbg' in line:
                print('     %4d| %s' % (i, line.strip()[:150]))

print('\n=== FuxiUsbCompat.c 其余部分 ===')
text = raw('package/FuxiUsbCompat.c')
for i, line in enumerate(text.splitlines()[69:], 70):
    print('%4d| %s' % (i, line[:160]))
