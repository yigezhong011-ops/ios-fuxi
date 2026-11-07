#!/usr/bin/env python3
"""Add FuxiStatusBar.dylib to a gpu addon: a weak load command in the plugin, the plugin's page 0 hash and code directory updated.
Usage: add-statusbar-dylib.py <addon in> <dylib> <addon out> <cdhashes out>"""
import hashlib, struct, sys, zlib

ADDONS = 'addons/NativeAdrenoMetal.bundle/'
PLUGIN, DYLIB = ADDONS + 'NativeAdrenoMetal', ADDONS + 'FuxiStatusBar.dylib'
LOADER = b'@loader_path/FuxiStatusBar.dylib\0'
def pad8(n): return n + (-n % 8)
def read_addon(path):
    b = open(path, 'rb').read(); assert b[:8] == b'NGPUADD2'
    count = struct.unpack_from('<I', b, 8)[0]; at = 24; out = []
    for _ in range(count):
        nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at); at += 24
        name = b[at:at + nl - 1].decode(); at += pad8(nl)
        out.append([name, mode, size, b[at:at + packed]]); at += pad8(packed)
    return out
def write_addon(path, entries):
    body = b''
    for n, m, s, pk in entries:
        e = n.encode() + b'\0'
        body += struct.pack('<IIQQ', len(e), m, s, len(pk)) + e + bytes(-len(e) % 8) + pk + bytes(-len(pk) % 8)
    open(path, 'wb').write(b'NGPUADD2' + struct.pack('<IIQ', len(entries), 0, 24 + len(body)) + body)
def signature(m):
    ncmds = struct.unpack_from('<I', m, 16)[0]; at = 32
    for _ in range(ncmds):
        c, l = struct.unpack_from('<II', m, at)
        if c == 0x1d: return struct.unpack_from('<II', m, at + 8)
        at += l
    raise SystemExit('no code signature')
def directory(m):
    off, size = signature(m)
    n = struct.unpack_from('>I', m, off + 8)[0]
    for i in range(n):
        o = off + struct.unpack_from('>I', m, off + 12 + i * 8 + 4)[0]
        if struct.unpack_from('>I', m, o)[0] == 0xfade0c02: return o, struct.unpack_from('>I', m, o + 4)[0]
    raise SystemExit('no code directory')
def cdhash(m):
    o, l = directory(m)
    return hashlib.sha256(m[o:o + l]).hexdigest()[:40]

entries = read_addon(sys.argv[1])
by = {e[0]: e for e in entries}
assert DYLIB not in by
plugin = bytearray(zlib.decompress(by[PLUGIN][3]))
ncmds, sizecmds = struct.unpack_from('<II', plugin, 16)
end = 32 + sizecmds
cmd = struct.pack('<IIIIII', 0x80000018, pad8(24 + len(LOADER)), 24, 2, 0x10000, 0x10000) + LOADER
cmd += bytes(-len(cmd) % 8)
assert end + len(cmd) <= 4096 and not any(plugin[end:end + len(cmd)])
plugin[end:end + len(cmd)] = cmd
struct.pack_into('<II', plugin, 16, ncmds + 1, sizecmds + len(cmd))
o, l = directory(plugin)
hash_off, page = struct.unpack_from('>I', plugin, o + 16)[0], plugin[o + 39]
assert plugin[o + 36] == 32 and plugin[o + 37] == 2 and page == 12
plugin[o + hash_off:o + hash_off + 32] = hashlib.sha256(plugin[:4096]).digest()
by[PLUGIN][2], by[PLUGIN][3] = len(plugin), zlib.compress(bytes(plugin), 9)

# The dylib: ad hoc as the plugin is, without the linker-signed mark.
dylib = bytearray(open(sys.argv[2], 'rb').read())
o, l = directory(dylib)
flags = struct.unpack_from('>I', dylib, o + 12)[0]
struct.pack_into('>I', dylib, o + 12, flags & ~0x20000)
entries.insert(entries.index(by[PLUGIN]) + 1, [DYLIB, 0o755, len(dylib), zlib.compress(bytes(dylib), 9)])
entries = [e for e in entries if '.filler' not in e[0]]
write_addon(sys.argv[3], entries)
with open(sys.argv[4], 'w') as f:
    f.write(f'{cdhash(plugin)} NativeAdrenoMetal.bundle/NativeAdrenoMetal\n{cdhash(dylib)} NativeAdrenoMetal.bundle/FuxiStatusBar.dylib\n')
    for name in (ADDONS + 'libvulkan_freedreno.dylib', 'bin/adrenoprobed'):
        f.write(f'{cdhash(zlib.decompress(by[name][3]))} {name}\n')
print('plugin', cdhash(plugin), 'dylib', cdhash(dylib), len(dylib), 'bytes, flags', hex(flags), 'addon entries', len(entries))
