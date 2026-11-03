#!/usr/bin/env python3
"""Complete the log kit integration in UniXNUPkg: protocol headers and dec blocks."""
import shutil
from pathlib import Path

KIT = Path('/root/build/log-kit/Uefi/Common')
BASES = [Path('/root/build/unixnu/package/UniXNUPkg'),
         Path('/root/build/unixnu/out/fuxi/tree/package/UniXNUPkg')]

for base in BASES:
    if not base.is_dir():
        continue
    # 1. protocol headers
    proto = base / 'Include' / 'Protocol'
    proto.mkdir(parents=True, exist_ok=True)
    for src in (KIT / 'Include').glob('*.h'):
        shutil.copy2(src, proto / src.name)
        print('%-70s 头文件 %s' % (str(base)[-40:], src.name))

    # 2. dec blocks
    dec = base / 'UniXNUPkg.dec'
    text = dec.read_text()
    if 'gUniXNULogFlushProtocolGuid' in text:
        print('   dec 已有协议 GUID')
        continue

    if '[LibraryClasses]' not in text:
        text += '\n[LibraryClasses]\n'
    if 'AdvancedLogViewLib|' not in text:
        text = text.replace('[LibraryClasses]',
                            '[LibraryClasses]\n  AdvancedLogViewLib|Include/Library/AdvancedLogViewLib.h', 1)

    if '[Protocols]' in text:
        text = text.replace(
            '[Protocols]',
            '[Protocols]\n'
            '  gUniXNUMenuPluginProtocolGuid = { 0x1a9b2c4d, 0x5e6f, 0x4789, '
            '{ 0xab, 0xcd, 0xef, 0x12, 0x34, 0x56, 0x78, 0x9a } }\n'
            '  gUniXNULogFlushProtocolGuid = { 0x8c3f7d12, 0x9b4e, 0x4a21, '
            '{ 0xa6, 0x1f, 0x0b, 0x39, 0xd5, 0x67, 0x84, 0xe2 } }', 1)
    else:
        text += ('\n[Protocols]\n'
                 '  gUniXNUMenuPluginProtocolGuid = { 0x1a9b2c4d, 0x5e6f, 0x4789, '
                 '{ 0xab, 0xcd, 0xef, 0x12, 0x34, 0x56, 0x78, 0x9a } }\n'
                 '  gUniXNULogFlushProtocolGuid = { 0x8c3f7d12, 0x9b4e, 0x4a21, '
                 '{ 0xa6, 0x1f, 0x0b, 0x39, 0xd5, 0x67, 0x84, 0xe2 } }\n')
    dec.write_text(text)
    print('%-70s dec 已补协议与库' % str(base)[-40:])
