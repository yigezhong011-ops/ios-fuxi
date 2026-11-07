#!/usr/bin/env python3
"""Read the author's USB debug patch and compat layer."""
import urllib.request

H = {'User-Agent': 'dsh'}
REPO = 'ljhhkx529/unixnu-fuxi'
REF = 'old'


def raw(path):
    try:
        url = f'https://raw.githubusercontent.com/{REPO}/{REF}/{path}'
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败: %s)' % e


for path, limit in (('package/FuxiUsbCompat.c', 120),
                    ('patches/xnu/zzzd-fuxi-usb-debug.patch', 90)):
    text = raw(path)
    print('=' * 20, path, '(%d 行)' % len(text.splitlines()))
    for i, line in enumerate(text.splitlines()[:limit], 1):
        print('%4d| %s' % (i, line[:170]))
    print()
