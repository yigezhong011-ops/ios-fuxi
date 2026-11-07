#!/usr/bin/env python3
"""Does the author's UEFI (or their log kit) initialise USB?"""
import json
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}


def api(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {'error': str(e)}


def raw(repo, path, ref):
    try:
        url = f'https://raw.githubusercontent.com/{repo}/{ref}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception:
        return ''


for repo, ref in (('ljhhkx529/uefi-fuxi', 'old'), ('ljhhkx529/unixnu-log-kit', 'main')):
    tree = api(f'https://api.github.com/repos/{repo}/git/trees/{ref}?recursive=1')
    files = [t['path'] for t in tree.get('tree', []) if t['type'] == 'blob']
    print('=== %s (%s): %d 文件 ===' % (repo, ref, len(files)))
    usb = [f for f in files if any(k in f.lower() for k in ('usb', 'dwc3', 'qusb', 'phy'))]
    print('  USB 相关 %d 个:' % len(usb))
    for f in usb[:15]:
        print('   ', f)
    docs = [f for f in files if f.lower().endswith('.md')]
    print('  文档:', docs[:8])
    for d in docs[:2]:
        text = raw(repo, d, ref)
        hits = [l for l in text.splitlines() if any(k in l.lower() for k in ('usb', 'log', 'serial'))]
        if hits:
            print('  --- %s ---' % d)
            for line in hits[:8]:
                print('     ', line.strip()[:140])
    print()
