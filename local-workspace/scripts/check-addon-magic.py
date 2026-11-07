#!/usr/bin/env python3
"""What container is kernel.macho.gpuaddon?"""
from pathlib import Path

for p in (Path('/root/fuxi/pkg5/root/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'),
          Path('/root/fuxi/pkg-fts/root/EFI/UniXNU/Payloads/kernel.macho.gpuaddon')):
    if not p.exists():
        continue
    data = p.read_bytes()
    print(p, len(data), 'bytes')
    print('  头 32 字节:', data[:32].hex())
    print('  可打印:', ''.join(chr(b) if 32 <= b < 127 else '.' for b in data[:48]))
    break
