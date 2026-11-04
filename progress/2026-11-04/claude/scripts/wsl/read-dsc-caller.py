#!/usr/bin/env python3
"""Where does the nil dataStore come from? Disassembles PBFModalSceneDelegate's call site with selector stubs named, and lists the
framework's strings about the store. Read-only. Usage: read-dsc-caller.py <dsc dir>"""
import mmap
import re
import struct
import subprocess
import sys
from pathlib import Path

D = Path(sys.argv[1])
maps, files, images = [], {}, []
for f in sorted(D.glob('dyld_shared_cache_arm64*')):
    if f.stat().st_size == 0:
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
            images.append((addr, m[po:m.find(b'\0', po)].decode()))


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


def ptrstr(va):
    p = rd(va, 8)
    if not p:
        return None
    q = struct.unpack('<Q', p)[0]
    for cand in (q & 0xffffffffff, (q & 0xfffffffff) + 0x180000000):
        c = cstr(cand)
        if c:
            return c
    return None


def stub(va):
    """Name of an objc_msgSend selector stub or of a class ref loader."""
    code = rd(va, 12)
    if not code:
        return None
    a, b = struct.unpack_from('<II', code)
    if a & 0x9f000000 != 0x90000000:
        return None
    imm = ((a >> 29) & 3) | (((a >> 5) & 0x7ffff) << 2)
    if imm & (1 << 20):
        imm -= 1 << 21
    page = (va & ~0xfff) + (imm << 12)
    if b & 0xffc00000 == 0xf9400000:
        return ptrstr(page + (((b >> 10) & 0xfff) << 3))
    if b & 0xff800000 == 0x91000000:
        return cstr(page + ((b >> 10) & 0xfff))
    return None


base = [x for x in images if x[1].endswith('/PosterBoard.framework/PosterBoard')][0][0]


def macho_sections():
    hdr = rd(base, 0x8000)
    n = struct.unpack_from('<I', hdr, 16)[0]
    at, out = 32, {}
    for _ in range(n):
        cmd, size = struct.unpack_from('<II', hdr, at)
        if cmd == 0x19:
            nsect = struct.unpack_from('<I', hdr, at + 64)[0]
            for i in range(nsect):
                s = at + 72 + i * 80
                out[hdr[s:s + 16].rstrip(b'\0').decode()] = struct.unpack_from('<QQ', hdr, s + 32)
        at += size
    return out


sec = macho_sections()
print({k: hex(v[1]) for k, v in sec.items() if 'string' in k or k == '__text'})
for name in ('__cstring', '__oslogstring'):
    if name in sec:
        a, s = sec[name]
        for t in rd(a, s).split(b'\0'):
            t = t.decode('latin1')
            if re.search(r'(?i)data ?store|migrat|fatal|failed to (create|load|open|init)|container|group\.com', t):
                print(f'  [{name}] {t[:150]}')


def dump(start, n, mark=None):
    Path('/root/fuxi/pbf2.bin').write_bytes(rd(start, n))
    out = subprocess.run(['aarch64-linux-gnu-objdump', '-D', '-b', 'binary', '-m', 'aarch64', f'--adjust-vma={start:#x}', '/root/fuxi/pbf2.bin'],
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
        elif ins & 0xff800000 == 0x91000000 and (ins >> 5) & 31 in regs:
            t = regs[(ins >> 5) & 31] + ((ins >> 10) & 0xfff)
            c = cstr(t) or ptrstr(t + 16)
            note = f'  ; {c!r}' if c else ''
        elif ins & 0xfc000000 == 0x94000000:
            imm = ins & 0x3ffffff
            if imm & (1 << 25):
                imm -= 1 << 26
            c = stub(va + imm * 4)
            note = f'  ; [{c}]' if c else ''
        print(f'{va:#x}{"*" if va == mark else " "}{text}{note}')


for addr in sys.argv[2:]:
    a = int(addr, 16)
    print('== around', hex(a))
    dump(a - 0xe0, 0x130, a)
