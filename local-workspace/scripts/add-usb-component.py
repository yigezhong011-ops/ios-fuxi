#!/usr/bin/env python3
"""Add UsbPwrEnablerDxe to the fuxi [Components] list."""
from pathlib import Path

dsc = Path('/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/fuxi.dsc')
text = dsc.read_text()
lines = text.splitlines()

if any(l.strip().startswith('NicobarPkg/Drivers/UsbPwrEnablerDxe') for l in lines):
    print('已经在 [Components] 里')
    raise SystemExit()

# insert after the FatPkg line, keeping the board-driver comment block intact
for i, line in enumerate(lines):
    if line.strip() == 'FatPkg/EnhancedFatDxe/Fat.inf':
        lines.insert(i + 1, '  NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf')
        print('已插入到第 %d 行之后' % (i + 1))
        break
else:
    raise SystemExit('找不到 FatPkg 那一行')

dsc.write_text('\n'.join(lines) + '\n')
for n, line in enumerate(dsc.read_text().splitlines(), 1):
    if 'UsbPwrEnabler' in line or 'FuxiUfsLog' in line or 'FuxiUefiLog' in line:
        print('%4d| %s' % (n, line))
