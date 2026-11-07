#!/usr/bin/env python3
"""Add UsbMsdDxe to the fuxi firmware, the one USB module the SM8550 reference platform
(qrd8550) loads and fuxi does not.

Without a function/class driver nothing calls into UsbDeviceDxe with a configuration, so
the controller never starts a device session and the host enumerates nothing at all, which
is what we see at the UniXNU menu.
"""
from pathlib import Path

PKG = Path('/root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg')
DXE = PKG / 'Include' / 'DXE.inc'
APR = PKG / 'Include' / 'APRIORI.inc'
LINE = '  INF Binaries/nuwa/QcomPkg/Drivers/UsbMsdDxe/UsbMsdDxe.inf\n'

for path, anchor in ((DXE, 'UsbDeviceDxe/UsbDeviceDxe.inf'),
                     (APR, 'UsbDeviceDxe/UsbDeviceDxe.inf')):
    text = path.read_text()
    if 'UsbMsdDxe' in text:
        print('%s: 已有' % path.name)
        continue
    out, done = [], False
    for line in text.splitlines(keepends=True):
        if not done and anchor in line:
            out.append(LINE)
            done = True
        out.append(line)
    if not done:
        print('%s: 找不到锚点 %s' % (path.name, anchor))
        continue
    path.write_text(''.join(out))
    print('%s: 已插入 UsbMsdDxe' % path.name)

for path in (DXE, APR):
    print('\n--- %s 的 USB 行 ---' % path.name)
    for n, line in enumerate(path.read_text().splitlines(), 1):
        if 'Usb' in line and 'INF' in line:
            print('%4d| %s' % (n, line.strip()[:100]))
