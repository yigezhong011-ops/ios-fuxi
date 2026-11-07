#!/usr/bin/env python3
"""What do the USB patches and the usbnet tool do?"""
import urllib.request

H = {'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}
REPO = 'yigezhong011-ops/ios-fuxi'


def raw(path):
    url = f'https://raw.githubusercontent.com/{REPO}/main/{path}'
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=60) as r:
            return r.read().decode('utf-8', 'replace')
    except Exception as e:
        return '(读取失败: %s)' % e


for path in ('tools/sweet-usbnet.sh',
             'xnu/patches/0073-sweet-usb-device-ep0.patch',
             'xnu/patches/0074-sweet-usb-vbus-override.patch',
             'xnu/patches/0075-sweet-usb-ecm.patch',
             'xnu/patches/0081-sweet-usb-link-state.patch'):
    text = raw(path)
    print('=== %s（%d 行）===' % (path, len(text.splitlines())))
    for line in text.splitlines()[:14]:
        print('   ', line[:150])
    print()
