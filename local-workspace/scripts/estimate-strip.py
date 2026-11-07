#!/usr/bin/env python3
# Read only on the input: estimates how far stripping shrinks the packed plugin, without a valid signature. Writes scratch files in /tmp.
import struct, subprocess, zlib
def entries(p):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = {}
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        r[n] = b[at:at + pk]; at += (pk + 7) // 8 * 8
    return r
e = entries('/root/fuxi/gpu-plugin-m2v/gpuaddon.bin')
def pack(raw):
    co = zlib.compressobj(9, zlib.DEFLATED, 15, 9)
    return len(co.compress(raw) + co.flush())
for name in ('addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal', 'addons/NativeAdrenoMetal.bundle/libvulkan_freedreno.dylib'):
    raw = zlib.decompress(e[name]); short = name.split('/')[-1]; p = '/tmp/est-' + short
    open(p, 'wb').write(raw)
    print(short, 'raw', len(raw), 'packed', len(e[name]), 'level 9', pack(raw))
    r = subprocess.run(['llvm-size', '-m', p], capture_output=True, text=True).stdout
    print('\n'.join(x for x in r.splitlines() if x.startswith('Segment'))[:400])
    for flags in (['--strip-debug'], ['-x'], ['--strip-all']):
        q = p + '.s'
        x = subprocess.run(['llvm-strip', *flags, p, '-o', q], capture_output=True, text=True)
        if x.returncode:
            print(flags, 'failed', x.stderr[:100]); continue
        s = open(q, 'rb').read()
        print(flags, 'raw', len(s), 'packed', pack(s))
    n = subprocess.run(['llvm-nm', p], capture_output=True, text=True).stdout.count('\n')
    print('symbols', n)
    old = zlib.decompress(entries('/tmp/addon-g7.bin')[name]) if name in entries('/tmp/addon-g7.bin') else b''
    print('old raw', len(old))
