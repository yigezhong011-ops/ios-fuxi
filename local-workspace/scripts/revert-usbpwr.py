#!/usr/bin/env python3
"""Back out the UsbPwrEnablerDxe addition.

The driver is a ginkgoPkg (SM6115) binary, and fuxiPkg/Include/DXE.inc already loads the
SM8550 USB device chain (UsbPwrCtrlDxe, UsbfnDwc3Dxe, UsbConfigDxe, UsbInitDxe, UCDxe,
QcomChargerDxe, ChargerExDxe) inside the FUXI_UFS_STACK block, so the extra driver was
redundant and addressed the wrong SoC.
"""
import re
from pathlib import Path

PKG = Path('/root/build/uefi-fuxi/Platforms/Xiaomi/fuxiPkg')
dsc = PKG / 'fuxi.dsc'
dxe = PKG / 'Include' / 'DXE.inc'

text = dsc.read_text()
text = re.sub(r'\n(  #[^\n]*\n)+  FUXI_USB_POWER\s*=\s*1\n', '\n', text, count=1)
text = text.replace(
    '  FatPkg/EnhancedFatDxe/Fat.inf\n'
    '!if $(FUXI_USB_POWER) == 1\n'
    '  NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n'
    '!endif\n',
    '  FatPkg/EnhancedFatDxe/Fat.inf\n', 1)
dsc.write_text(text)

text = dxe.read_text()
text = text.replace(
    '\n\n##\n'
    '# USB controller power, for the kernel USB debug console. See FUXI_USB_POWER.\n'
    '##\n'
    '!if $(FUXI_USB_POWER) == 1\n'
    '  INF NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.inf\n'
    '!endif\n', '\n')
dxe.write_text(text)

print('fuxi.dsc 里还有 FUXI_USB_POWER:', 'FUXI_USB_POWER' in dsc.read_text())
print('DXE.inc 里还有 UsbPwrEnabler:', 'UsbPwrEnabler' in dxe.read_text())
import subprocess
print(subprocess.run(['git', '-C', str(PKG), 'status', '--short', '--',
                      'Platforms/Xiaomi/fuxiPkg/fuxi.dsc',
                      'Platforms/Xiaomi/fuxiPkg/Include/DXE.inc'],
                     capture_output=True, text=True).stdout or '  （工作树干净，改动已还原）')
