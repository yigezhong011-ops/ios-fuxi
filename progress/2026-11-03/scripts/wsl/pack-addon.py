#!/usr/bin/env python3
"""Write an NGPUADD2 GPU addon from a plugin directory plus an optional wallpaper overlay.

Layout, little endian (from UniXNU scripts/make-gpu-addon.py):
  "NGPUADD2", u32 count, u32 0, u64 total bytes
  per file: u32 path bytes (with its NUL, at most 160), u32 mode, u64 size,
            u64 compressed size, the path padded to 8 bytes, the zlib stream padded to 8.

Usage: pack-addon.py <plugin-dir> <out> [--wallpaper DIR] [--clients a,b,c] [--publish]
The plugin directory holds NativeAdrenoMetal.bundle/, adrenoprobed and *.plist.
"""
import struct
import sys
import zlib
from pathlib import Path


def pad8(b):
    return b + bytes(-len(b) % 8)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    plugin, out = Path(sys.argv[1]), Path(sys.argv[2])
    args = sys.argv[3:]
    wallpaper = None
    clients = None
    publish = '--publish' in args
    for i, a in enumerate(args):
        if a == '--wallpaper':
            wallpaper = Path(args[i + 1])
        elif a == '--clients':
            clients = [c for c in args[i + 1].split(',') if c]

    files = []
    bundle = plugin / 'NativeAdrenoMetal.bundle'
    if not bundle.is_dir():
        sys.exit('no NativeAdrenoMetal.bundle in ' + str(plugin))
    for p in sorted(bundle.rglob('*')):
        if p.is_file():
            mode = 0o755 if p.name in ('NativeAdrenoMetal', 'libvulkan_freedreno.dylib') else 0o644
            files.append(('addons/NativeAdrenoMetal.bundle/' + p.relative_to(bundle).as_posix(),
                          mode, p.read_bytes()))
    if publish:
        files.append(('addons/NativeAdrenoMetal.publish', 0o644, b'1\n'))
    if clients:
        files.append(('addons/NativeAdrenoMetal.clients', 0o644,
                      ('\n'.join(clients) + '\n').encode()))
    probe = plugin / 'adrenoprobed'
    if probe.is_file():
        files.append(('bin/adrenoprobed', 0o755, probe.read_bytes()))
    for plist in sorted(plugin.glob('*.plist')):
        if not plist.name.endswith('-entitlements.plist'):
            files.append(('daemons/' + plist.name, 0o644, plist.read_bytes()))
    if wallpaper:
        if not (wallpaper / 'main.caml').is_file():
            sys.exit('wallpaper dir needs main.caml')
        for p in sorted(wallpaper.rglob('*')):
            if p.is_file():
                files.append(('wallpaper/' + p.relative_to(wallpaper).as_posix(), 0o644, p.read_bytes()))

    body = b''
    for name, mode, data in files:
        enc = name.encode() + b'\0'
        if len(enc) > 160:
            sys.exit('path too long: ' + name)
        packed = zlib.compress(data, 9)
        body += struct.pack('<IIQQ', len(enc), mode, len(data), len(packed)) + pad8(enc) + pad8(packed)
        print('  %-56s %9d → %9d' % (name[:56], len(data), len(packed)))
    blob = b'NGPUADD2' + struct.pack('<IIQ', len(files), 0, 24 + len(body)) + body
    out.write_bytes(blob)
    print('%s: %d 个条目, %d 字节' % (out.name, len(files), len(blob)))


main()
