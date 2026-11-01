"""Windows-side (no WSL, no LLVM) look at the t32 kernel's button path.

boot.img v3 -> gzip -> loader + FAT32 payload -> EFI/UniXNU/Payloads/kernel.macho -> Mach-O symbols.
Prints button / PON / SPMI symbols, the code of native_buttons_set_sink, the global it stores the sink in,
and every function that loads that global (the code that would deliver button presses).
Usage: python -I t32-buttons.py <boot.img> [out-kernel.macho]
"""
import struct
import sys
import zlib
from pathlib import Path

img = Path(sys.argv[1]).read_bytes()
ksize = struct.unpack_from('<I', img, 8)[0]
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(img[4096:4096 + ksize])
fat_off = next(m for m in range(0, 8 << 20, 2)
               if body[m + 0x52:m + 0x5a].startswith(b'FAT32') and body[m + 0x1fe:m + 0x200] == b'\x55\xaa')
vol = memoryview(body)[fat_off:]

# --- minimal FAT32 reader -------------------------------------------------------------------------
bps, spc, rsv, nfats = struct.unpack_from('<HBHB', vol, 11)
fatsz = struct.unpack_from('<I', vol, 36)[0]
root_clus = struct.unpack_from('<I', vol, 44)[0]
fat_start = rsv * bps
data_start = (rsv + nfats * fatsz) * bps
csize = spc * bps


def chain(c):
    while 2 <= c < 0x0ffffff8:
        yield c
        c = struct.unpack_from('<I', vol, fat_start + 4 * c)[0] & 0x0fffffff


def read_clusters(c, size=None):
    out = bytearray()
    for cl in chain(c):
        out += vol[data_start + (cl - 2) * csize:data_start + (cl - 1) * csize]
        if size is not None and len(out) >= size:
            break
    return bytes(out[:size] if size is not None else out)


def listdir(c):
    d, lfn = read_clusters(c), []
    for i in range(0, len(d), 32):
        e = d[i:i + 32]
        if e[0] == 0:
            break
        if e[0] == 0xe5:
            lfn = []
            continue
        if e[11] == 0x0f:
            lfn.insert(0, (e[1:11] + e[14:26] + e[28:32]).decode('utf-16le', 'ignore').split('\0')[0].rstrip('￿'))
            continue
        name = ''.join(lfn) or (e[0:8].decode().strip() + ('.' + e[8:11].decode().strip() if e[8:11].strip() else ''))
        lfn = []
        clus = struct.unpack_from('<H', e, 20)[0] << 16 | struct.unpack_from('<H', e, 26)[0]
        yield name, clus, struct.unpack_from('<I', e, 28)[0], bool(e[11] & 0x10)


def find(path):
    c = root_clus
    for part in path.split('/'):
        c, size, _ = next((cl, sz, d) for n, cl, sz, d in listdir(c) if n.lower() == part.lower())
    return read_clusters(c, size)


k = find('EFI/UniXNU/Payloads/kernel.macho')
print(f'kernel.macho {len(k)} bytes')
if len(sys.argv) > 2:
    Path(sys.argv[2]).write_bytes(k)

# --- Mach-O: segments and symbols ----------------------------------------------------------------
magic, _, _, _, ncmds = struct.unpack_from('<5I', k, 0)
assert magic == 0xfeedfacf, hex(magic)
segs, syms, off = [], {}, 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, off)
    if cmd == 0x19:
        name = k[off + 8:off + 24].split(b'\0')[0].decode()
        vmaddr, vmsize, fileoff, filesize = struct.unpack_from('<4Q', k, off + 24)
        segs.append((name, vmaddr, vmsize, fileoff, filesize))
    elif cmd == 0x2:
        symoff, nsyms, stroff, strsize = struct.unpack_from('<4I', k, off + 8)
        for i in range(nsyms):
            strx, ntype, nsect, ndesc, value = struct.unpack_from('<IBBHQ', k, symoff + 16 * i)
            if ntype & 0x0e == 0x0e and value:
                end = k.index(b'\0', stroff + strx)
                syms[k[stroff + strx:end].decode(errors='replace')] = value
    off += size
print(f'{len(syms)} defined symbols, segments: ' + ', '.join(s[0] for s in segs))


def foff(va):
    for _, vmaddr, vmsize, fileoff, filesize in segs:
        if vmaddr <= va < vmaddr + filesize:
            return fileoff + va - vmaddr
    return None


by_addr = sorted((v, n) for n, v in syms.items())


def owner(va):
    lo, hi = 0, len(by_addr)
    while lo < hi:
        mid = (lo + hi) // 2
        if by_addr[mid][0] <= va:
            lo = mid + 1
        else:
            hi = mid
    return by_addr[lo - 1][1] if lo else '?'


print('\n== button / PON / SPMI / keypad symbols')
for n, v in sorted(syms.items(), key=lambda x: x[1]):
    low = n.lower()
    if any(w in low for w in ('button', 'pon_', '_pon', 'spmi', 'pmic', 'keypad', 'volume', 'hidinput')):
        print(f'  {v:#x} {n}')

# --- native_buttons_set_sink: decode ADRP/ADD/STR to find the sink global ----------------------
def sx(v, bits):
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


def adrp_target(pc, w):
    imm = ((w >> 29) & 3) | (((w >> 5) & 0x7ffff) << 2)
    return (pc & ~0xfff) + (sx(imm, 21) << 12)


fn = syms.get('_native_buttons_set_sink')
print(f'\n== _native_buttons_set_sink at {fn:#x}' if fn else '\n_native_buttons_set_sink not found')
globals_written = set()
if fn:
    base = None
    for i in range(16):
        pc = fn + 4 * i
        w = struct.unpack_from('<I', k, foff(pc))[0]
        print(f'  {pc:#x}: {w:08x}')
        if w & 0x9f000000 == 0x90000000:
            base = adrp_target(pc, w)
        elif base is not None and w & 0xffc00000 == 0xf9000000:      # STR Xt, [Xn, #imm]
            globals_written.add(base + ((w >> 10) & 0xfff) * 8)
        elif base is not None and w & 0xff800000 == 0x91000000:      # ADD Xd, Xn, #imm
            base += (w >> 10) & 0xfff
        if w == 0xd65f03c0:
            break
print('  stores to:', ', '.join(f'{g:#x} ({owner(g)})' for g in sorted(globals_written)) or 'none decoded')

# --- who loads those globals (ADRP page + LDR/ADD within the next few instructions) -------------
if globals_written:
    text = [s for s in segs if s[0] == '__TEXT_EXEC']
    pages = {g & ~0xfff for g in globals_written}
    readers = {}
    for _, vmaddr, vmsize, fileoff, filesize in text:
        code = k[fileoff:fileoff + filesize]
        for i in range(0, len(code) - 4, 4):
            w = struct.unpack_from('<I', code, i)[0]
            if w & 0x9f000000 != 0x90000000:
                continue
            pc = vmaddr + i
            page = adrp_target(pc, w)
            if page not in pages:
                continue
            rd = w & 0x1f
            for j in range(1, 6):
                w2 = struct.unpack_from('<I', code, i + 4 * j)[0]
                if (w2 >> 5) & 0x1f != rd:
                    continue
                if w2 & 0xffc00000 == 0xf9400000:                     # LDR Xt, [Xn, #imm]
                    tgt = page + ((w2 >> 10) & 0xfff) * 8
                elif w2 & 0xff800000 == 0x91000000:                   # ADD
                    tgt = page + ((w2 >> 10) & 0xfff)
                else:
                    continue
                if tgt in globals_written:
                    readers.setdefault(owner(pc), set()).add(f'{pc + 4 * j:#x}')
    print('\n== functions that load the sink global')
    for name, pcs in sorted(readers.items()):
        print(f'  {name}  at {", ".join(sorted(pcs))}')
