#!/usr/bin/env python3
"""Which assertion in -[PBFModalRootViewController initWithScene:dataStore:behaviorAssertionProvider:] fired? Read-only.
Usage: read-dsc-assert.py <dir with dyld_shared_cache_arm64* files> [image offset]"""
import mmap
import re
import struct
import subprocess
import sys
from pathlib import Path

D = Path(sys.argv[1])
OFF = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0x4b7a4
maps = []
files = {}
images = []
for f in sorted(D.glob('dyld_shared_cache_arm64*')):
    if f.suffix in ('.map', '.atlas') or f.stat().st_size == 0:
        continue
    fh = f.open('rb')
    m = mmap.mmap(fh.fileno(), 0, access=mmap.ACCESS_READ)
    if m[:4] != b'dyld':
        continue
    files[f.name] = m
    moff, mcnt = struct.unpack_from('<II', m, 16)
    for i in range(mcnt):
        a, s, o = struct.unpack_from('<QQQ', m, moff + i * 32)
        maps.append((a, s, o, f.name))
    ioff, icnt = struct.unpack_from('<II', m, 0x1c0)
    if icnt and not images:
        for i in range(icnt):
            addr, _, _, po = struct.unpack_from('<QQQI', m, ioff + i * 32)
            e = m.find(b'\0', po)
            images.append((addr, m[po:e].decode()))
print('files', len(files), 'mappings', len(maps), 'images', len(images))


def rd(va, n):
    for a, s, o, name in maps:
        if a <= va < a + s:
            return files[name][o + va - a:o + va - a + n]
    return None


def cstr(va):
    b = rd(va, 300)
    if not b:
        return None
    b = b.split(b'\0')[0]
    return b.decode('latin1') if b and all(32 <= c < 127 for c in b) else None


hits = [x for x in images if re.search(r'/PosterBoard(\.framework/PosterBoard|Framework|Services)?', x[1]) and 'PosterBoard' in x[1]]
for a, p in hits[:12]:
    print(hex(a), p)
fw = [x for x in images if x[1].endswith('/PosterBoard.framework/PosterBoard')] or hits
base = fw[0][0]
pc = base + OFF
print('framework', fw[0][1], 'base', hex(base), 'pc', hex(pc))
START = pc - 0x340
code = rd(START, 0x360)
Path('/root/fuxi/pbf.bin').write_bytes(code)
out = subprocess.run(['aarch64-linux-gnu-objdump', '-D', '-b', 'binary', '-m', 'aarch64', f'--adjust-vma={START:#x}', '/root/fuxi/pbf.bin'],
                     capture_output=True, text=True).stdout
regs = {}
for line in out.splitlines():
    m = re.match(r'\s*([0-9a-f]+):\s+([0-9a-f]{8})\s+(.*)', line)
    if not m:
        continue
    va, ins, text = int(m[1], 16), int(m[2], 16), m[3]
    note = ''
    if ins & 0x9f000000 == 0x90000000:
        imm = ((ins >> 29) & 3) | (((ins >> 5) & 0x7ffff) << 2)
        if imm & (1 << 20):
            imm -= 1 << 21
        regs[ins & 31] = (va & ~0xfff) + (imm << 12)
    elif ins & 0xff800000 == 0x91000000:
        s = (ins >> 5) & 31
        if s in regs:
            t = regs[s] + ((ins >> 10) & 0xfff)
            regs[ins & 31] = t
            c = cstr(t)
            if c is None:
                p = rd(t + 16, 8)
                if p:
                    q = struct.unpack('<Q', p)[0]
                    for cand in (q & 0xffffffffff, (q & 0xfffffffff) + 0x180000000, q & 0xffffffff | (base & ~0xffffffff)):
                        c = cstr(cand)
                        if c:
                            c = '@' + c
                            break
            note = f'  ; {t:#x} {c!r}' if c else f'  ; {t:#x}'
    elif ins & 0xffc00000 == 0xf9400000:
        s = (ins >> 5) & 31
        if s in regs:
            t = regs[s] + (((ins >> 10) & 0xfff) << 3)
            p = rd(t, 8)
            c = None
            if p:
                q = struct.unpack('<Q', p)[0]
                for cand in (q & 0xffffffffff, (q & 0xfffffffff) + 0x180000000):
                    c = cstr(cand)
                    if c:
                        break
            note = f'  ; [{t:#x}] sel/ptr {c!r}' if c else f'  ; [{t:#x}]'
    mark = '  <== crash' if va == pc else ''
    print(f'{va:#x} {text}{note}{mark}')
