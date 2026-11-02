#!/usr/bin/env python3
"""Pull houji's client-window table and slot policy, with line numbers, for the request."""
import urllib.request

H = {'User-Agent': 'dsh'}
PATH = ('archive/native/gpu/cached-query-runtime/after/iokit/Kernel/houji-ufs-root/'
        'Adreno740/NativeAdrenoPublish.cpp')
URL = f'https://raw.githubusercontent.com/lonzzi/UniXNU-houji/main/{PATH}'

text = urllib.request.urlopen(urllib.request.Request(URL, headers=H), timeout=60).read().decode('utf-8', 'replace')
lines = text.splitlines()
print('文件 %d 行' % len(lines))

keys = ('kClientWindows', 'NativeAdrenoMaxClients', 'GeneralClients', 'PreferencesSlot',
        'MAX_CLIENTS', 'ClientWindow')
shown = set()
for i, line in enumerate(lines):
    if any(k in line for k in keys):
        lo, hi = max(0, i - 2), min(len(lines), i + 14)
        block = (lo, hi)
        if block in shown:
            continue
        shown.add(block)
        print('\n--- %d ---' % (i + 1))
        for j in range(lo, hi):
            print('   %4d| %s' % (j + 1, lines[j][:165]))
