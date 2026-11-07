#!/usr/bin/env python3
"""Read only: the addon's entries and the plugin's load commands and code signature. Usage: read-addon-plugin.py <addon>"""
import hashlib, struct, sys, zlib

def pad8(n): return n + (-n % 8)
b = open(sys.argv[1], 'rb').read()
count = struct.unpack_from('<I', b, 8)[0]; at = 24; entries = {}
for _ in range(count):
    nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at); at += 24
    name = b[at:at + nl - 1].decode(); at += pad8(nl)
    entries[name] = (mode, size, b[at:at + packed]); at += pad8(packed)
    print(oct(mode), size, packed, name)
name = next(n for n in entries if n.endswith('.bundle/NativeAdrenoMetal'))
m = zlib.decompress(entries[name][2])
magic, cpu, sub, ft, ncmds, sizecmds, flags = struct.unpack_from('<IIIIIII', m, 0)
print('\nplugin', name, hex(magic), hex(cpu), hex(sub), 'filetype', ft, 'cmds', ncmds, 'sizecmds', sizecmds, 'flags', hex(flags))
if magic != 0xfeedfacf: sys.exit('not thin 64')
at = 32; first = None; cs = None
for _ in range(ncmds):
    c, l = struct.unpack_from('<II', m, at)
    if c in (0xc, 0x18 | 0x80000000, 0xd, 0x1f | 0x80000000):
        print('dylib', hex(c), m[at + struct.unpack_from('<I', m, at + 8)[0]:at + l].split(b'\0')[0].decode())
    if c == 0x19:
        seg = m[at + 8:at + 24].split(b'\0')[0].decode(); va, vs, fo, fs = struct.unpack_from('<QQQQ', m, at + 24); ns = struct.unpack_from('<I', m, at + 64)[0]
        print('segment', seg, hex(va), hex(vs), hex(fo), hex(fs), 'sects', ns)
        for i in range(ns):
            so = at + 72 + i * 80; off = struct.unpack_from('<I', m, so + 48)[0]
            if off and (first is None or off < first): first = off
    if c == 0x1d:
        cs = struct.unpack_from('<II', m, at + 8); print('code signature at', hex(cs[0]), hex(cs[1]))
    if c in (0x22, 0x80000022, 0x80000033, 0x80000034): print('linkedit cmd', hex(c))
    at += l
print('commands end', hex(at), 'first section', hex(first), 'free', first - at, 'file', hex(len(m)))
if cs:
    sb = m[cs[0]:cs[0] + cs[1]]
    magic, length, n = struct.unpack_from('>III', sb, 0)
    print('superblob', hex(magic), length, n)
    for i in range(n):
        t, o = struct.unpack_from('>II', sb, 12 + i * 8)
        mg, ln = struct.unpack_from('>II', sb, o)
        print(' slot', hex(t), 'magic', hex(mg), 'len', ln)
        if mg == 0xfade0c02:
            f = struct.unpack_from('>IIIIIIIIIBBBBI', sb, o)
            print('  version', hex(f[2]), 'flags', hex(f[3]), 'hashOff', f[4], 'identOff', f[5], 'special', f[6], 'code', f[7], 'limit', hex(f[8]), 'hashSize', f[9], 'type', f[10], 'platform', f[11], 'pageSize', f[12])
            print('  ident', sb[o + f[5]:o + f[5] + 80].split(b'\0')[0].decode(errors='replace'), 'cdhash', hashlib.sha256(sb[o:o + ln]).hexdigest()[:40])
            if f[2] >= 0x20400: print('  execseg', struct.unpack_from('>QQQ', sb, o + 64))
            for s in range(1, f[6] + 1):
                print('  special', s, sb[o + f[4] - s * f[9]:o + f[4] - (s - 1) * f[9]].hex()[:16])
