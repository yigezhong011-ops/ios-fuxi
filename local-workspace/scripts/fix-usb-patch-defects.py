#!/usr/bin/env python3
"""Fix the two defects the handoff lists for 0001-fuxi-usb-power.patch:

1. the Chinese comments in fuxi.dsc came out as mojibake and merged two lines; use English
2. [Components] added the driver unconditionally while DXE.inc gated it on FUXI_USB_POWER;
   both sides now use the same switch
"""
import re
from pathlib import Path

PKG = Path('/root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg')
dsc = PKG / 'fuxi.dsc'
dxe = PKG / 'Include' / 'DXE.inc'

text = dsc.read_text(encoding='utf-8', errors='replace')

# 1. replace whatever comment block sits between FUXI_UFS_STACK and FUXI_USB_POWER
text = re.sub(
    r'\n(  #[^\n]*\n)+  FUXI_USB_POWER\s*=\s*1\n',
    '\n  #\n'
    '  # 1 = power the USB controller (UsbPwrEnablerDxe) before hand-off. The kernel\'s\n'
    '  #     QcomXnuUsbDebug reads VBUS at init and only then pulls D+ up; without it the\n'
    '  #     host never enumerates the CDC ACM console. Power only: no UEFI USB device\n'
    '  #     stack change, no display change.\n'
    '  #\n'
    '  FUXI_USB_POWER                 = 1\n',
    text, count=1)

# 2. gate the [Components] entry on the same switch
text = text.replace(
    '  FatPkg/EnhancedFatDxe/Fat.inf\n'
    '  NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n',
    '  FatPkg/EnhancedFatDxe/Fat.inf\n'
    '!if $(FUXI_USB_POWER) == 1\n'
    '  NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n'
    '!endif\n', 1)

dsc.write_text(text)

print('--- fuxi.dsc 开关 ---')
for line in dsc.read_text().splitlines():
    if 'FUXI_USB_POWER' in line or 'UsbPwrEnabler' in line:
        print('   ', line.strip())

# sanity: no non-ASCII left in the block we touched
bad = [l for l in dsc.read_text().splitlines()
       if 'FUXI_USB_POWER' in l or ('UsbPwr' in l)]
print('非 ASCII 行数:', sum(1 for l in bad if any(ord(c) > 127 for c in l)))
