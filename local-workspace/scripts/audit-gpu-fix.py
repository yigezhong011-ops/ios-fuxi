#!/usr/bin/env python3
"""Independent audit of a *-gpu-fix.img against its base volume and the CI output. Read-only.
Usage: audit-gpu-fix.py <base name, t50-mine|t36-bl2>"""
import hashlib
import struct
import subprocess
import sys
import zlib
from pathlib import Path

base = sys.argv[1]
img = Path(f'/mnt/e/DSH-Fuxi/{base}-gpu-fix.img').read_bytes()
base_vol = Path(f'/root/fuxi/{base}/vol.img').read_bytes()
ci = Path(f'/root/fuxi/gpu-new-{base}')

hs, ks = struct.unpack_from('<I', img, 20)[0], struct.unpack_from('<I', img, 8)[0]
start = (hs + 4095) // 4096 * 4096
body = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(img[start:start + ks])
fat = next(m for m in range(0, 8 << 20, 2) if body[m + 0x52:m + 0x57] == b'FAT32' and body[m + 0x1fe:m + 0x200] == b'\x55\xaa')
total = struct.unpack_from('<I', body, fat + 32)[0] * 512
vol = body[fat:fat + total]
out = Path(f'/tmp/audit-{base}.vol')
out.write_bytes(vol)
print(f'== {base}: image {len(img)}, volume {len(vol)}, base volume {len(base_vol)}')

# Which bytes of the volume differ from the base (4K granularity), should be only the two files.
assert len(vol) == len(base_vol)
runs, at, step = [], None, 4096
for o in range(0, len(vol), step):
    if vol[o:o + step] != base_vol[o:o + step]:
        if at is None:
            at = o
    elif at is not None:
        runs.append((at, o)); at = None
if at is not None:
    runs.append((at, len(vol)))
print('differing ranges vs base:', [(hex(a), b - a) for a, b in runs])


def mtype(v, p):
    return subprocess.run(['mtype', '-i', str(v), p], capture_output=True, env={'MTOOLS_SKIP_CHECK': '1', 'PATH': '/usr/bin:/bin'}).stdout


def parse(blob):
    assert blob[:8] == b'NGPUADD2', blob[:8]
    count, _, tot = struct.unpack_from('<IIQ', blob, 8)
    assert tot == len(blob), (tot, len(blob))
    off, res = 24, {}
    for _ in range(count):
        nlen, mode, size, csize = struct.unpack_from('<IIQQ', blob, off)
        off += 24
        name = blob[off:off + nlen - 1].decode()
        off += nlen + (-nlen % 8)
        raw = zlib.decompress(blob[off:off + csize])
        assert len(raw) == size, name
        off += csize + (-csize % 8)
        res[name] = (mode, raw)
    assert off == len(blob)
    return res


def cdhash(macho):
    """CDHash of a thin arm64 Mach-O: truncated hash of its best CodeDirectory."""
    if macho[:4] != b'\xcf\xfa\xed\xfe':
        return None
    ncmds = struct.unpack_from('<I', macho, 16)[0]
    off = 32
    for _ in range(ncmds):
        cmd, size = struct.unpack_from('<II', macho, off)
        if cmd == 0x1d:
            so, ss = struct.unpack_from('<II', macho, off + 8)
            sb = macho[so:so + ss]
            n = struct.unpack_from('>I', sb, 8)[0]
            best = None
            for i in range(n):
                t, o = struct.unpack_from('>II', sb, 12 + i * 8)
                if t == 0 or 0x1000 <= t < 0x1005:
                    ln = struct.unpack_from('>I', sb, o + 4)[0]
                    cd = sb[o:o + ln]
                    ht = cd[37]
                    h = hashlib.sha256(cd).digest()[:20] if ht == 2 else hashlib.sha1(cd).digest()
                    if best is None or ht == 2:
                        best = h
            return best.hex() if best else None
        off += size
    return None


new = parse(mtype(out, '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'))
old = parse(mtype(f'/root/fuxi/{base}/vol.img', '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'))
print('-- addon entries (name, mode, size old, size new, cdhash new)')
for name in sorted(set(old) | set(new)):
    o, n = old.get(name), new.get(name)
    print('  %-60s %6s %10s %10s %s' % (name, oct((n or o)[0]), len(o[1]) if o else '-', len(n[1]) if n else '-', cdhash(n[1]) if n else ''))

t = mtype(out, '::/EFI/UniXNU/Payloads/kernel.macho.trustcache')
s0 = struct.unpack_from('<I', t, 4)[0]
c = struct.unpack_from('<I', t, s0 + 20)[0]
trust = [t[s0 + 24 + i * 24:s0 + 44 + i * 24].hex() for i in range(c)]
print('-- owner trust', trust)
hashes = {cdhash(v[1]): k for k, v in new.items() if cdhash(v[1])}
for h in trust:
    print('  ', h, '->', hashes.get(h, 'NOT IN ADDON'))
for h, k in hashes.items():
    if h not in trust:
        print('   addon Mach-O not in the owner module:', k, h)
print('-- ci cdhashes.txt'); print((ci / 'cdhashes.txt').read_text().strip())
print('-- ci revisions'); print((ci / 'revisions.txt').read_text().strip())
for marker in (b'no linear image', b'written-host', b'linear image'):
    print('   string', marker, {k: v[1].count(marker) for k, v in new.items() if marker in v[1]}, 'old', {k: v[1].count(marker) for k, v in old.items() if marker in v[1]})
print('-- same files outside the two payloads:')
for p in ('::/EFI/UniXNU/Payloads/kernel.macho', '::/EFI/UniXNU/boot.toml', '::/EFI/UniXNU/unixnu.toml'):
    a, b = mtype(out, p), mtype(f'/root/fuxi/{base}/vol.img', p)
    print('  ', p, len(a), 'same' if a == b else 'DIFFERENT')
