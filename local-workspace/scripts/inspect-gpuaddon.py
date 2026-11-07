#!/usr/bin/env python3
"""Inspect the payload addon: does it already carry the Metal plugin bundle and
the adrenoprobed pieces the seed script would stage?"""
from pathlib import Path

p = Path('/root/fuxi/expert-gpuaddon.img')
src = Path('/root/fuxi/pl/EFI/UniXNU/Payloads/kernel.macho.gpuaddon')
if src.exists():
    p.write_bytes(src.read_bytes())
data = p.read_bytes()
print('addon %d 字节' % len(data))
print('前 16 字节:', data[:16].hex(), repr(data[:8]))
print()
for name in (b'NativeAdrenoMetal.bundle', b'NativeAdrenoMetal.publish', b'NativeAdrenoMetal.clients',
             b'adrenoprobed', b'MetalPluginName', b'DBRDISK', b'NGPUADD', b'APFS', b'HFS'):
    print('  %-28s %s' % (name.decode(errors='replace'), '有' if name in data else '没有'))
