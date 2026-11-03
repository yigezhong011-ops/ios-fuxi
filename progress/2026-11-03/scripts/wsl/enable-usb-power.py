#!/usr/bin/env python3
"""Enable the USB power enabler in the fuxi firmware.

The kernel's QcomXnuUsbDebug expects the firmware to have powered and clocked the USB
controller ("the backend uses the SM8550 USB state prepared by the firmware"), and the
fuxi build currently loads only the vendor stack UFS needs, which excludes USB. This adds
NicobarPkg/Drivers/UsbPwrEnablerDxe behind a FUXI_USB_POWER switch, leaving the display
path untouched.
"""
import re
from pathlib import Path

PKG = Path('/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg')
dsc = PKG / 'fuxi.dsc'
dxe = PKG / 'Include' / 'DXE.inc'

# 1. the switch, next to FUXI_UFS_STACK
text = dsc.read_text()
if 'FUXI_USB_POWER' not in text:
    anchor = '  FUXI_UFS_STACK                 = 1\n'
    if anchor not in text:
        raise SystemExit('在 fuxi.dsc 里找不到 FUXI_UFS_STACK 行')
    text = text.replace(anchor, anchor + (
        '  #\n'
        '  # 1 = 给 USB 控制器上电（UsbPwrEnablerDxe），内核的 QcomXnuUsbDebug 需要固件先把\n'
        '  #     USB 供电准备好，否则它拿不到 VBUS，不做 D+ 上拉，主机看不到串口。\n'
        '  #     只加上电，不加载 UEFI 的 USB 设备栈，也不碰显示。\n'
        '  #\n'
        '  FUXI_USB_POWER                 = 1\n'), 1)
    dsc.write_text(text)
    print('fuxi.dsc: 已加入 FUXI_USB_POWER = 1')
else:
    print('fuxi.dsc: 开关已存在')

# 2. build the driver: add it to [Components] if the DSC lists them explicitly
text = dsc.read_text()
if 'UsbPwrEnablerDxe' not in text:
    m = re.search(r'^\[Components\][^\n]*\n', text, re.M)
    if m:
        insert = ('NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n')
        pos = m.end()
        text = text[:pos] + insert + text[pos:]
        dsc.write_text(text)
        print('fuxi.dsc: [Components] 已加入 UsbPwrEnablerDxe')
    else:
        print('fuxi.dsc: 没有 [Components] 段（组件由 include 提供），跳过')
else:
    print('fuxi.dsc: 已有 UsbPwrEnablerDxe')

# 3. load it at boot
text = dxe.read_text()
if 'UsbPwrEnablerDxe' not in text:
    text = text.rstrip('\n') + (
        '\n\n##\n'
        '# USB controller power, for the kernel USB debug console. See FUXI_USB_POWER.\n'
        '##\n'
        '!if $(FUXI_USB_POWER) == 1\n'
        '  INF NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n'
        '!endif\n')
    dxe.write_text(text)
    print('DXE.inc: 已加入 UsbPwrEnablerDxe')
else:
    print('DXE.inc: 已有 UsbPwrEnablerDxe')

print()
print('--- fuxi.dsc 开关 ---')
for line in dsc.read_text().splitlines():
    if 'FUXI_' in line and '=' in line:
        print('   ', line.strip())
