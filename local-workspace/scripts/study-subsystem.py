# Read-only: subsystem names PosterBoard and friends log under, and how libsystem_trace uses Enable-Private-Data. Run from dump/wsl with -I.
import importlib.util, re, struct, sys, bisect
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
sn = c.sec['__cstring'] if '__cstring' in c.sec else None
a, n = c.sec['__cstring']
s = bytes(c.rd(a, n))
names = sorted({x.decode() for x in re.findall(rb'com\.apple\.[A-Za-z.]*[Pp]oster[A-Za-z.]*', s)})
print('poster strings in the framework:', names[:30])
# strings around the key in libsystem_trace
K = 0x1a0717c41
b = bytes(c.rd(K - 500, 800))
print([x.decode('latin1') for x in b.split(b'\0') if len(x) > 2])
# xrefs to the key in libsystem_trace: adrp+add
imgs = sorted(c.images); addrs = [x for x, _ in imgs]
i = next(j for j, (x, nm) in enumerate(imgs) if nm.endswith('libsystem_trace.dylib'))
base = imgs[i][0]; size = imgs[i + 1][0] - base
hdr = bytes(c.rd(base, 0x8000))
ncmds = struct.unpack_from('<I', hdr, 16)[0]; o = 32; tx = None
for _ in range(ncmds):
    cmd, sz = struct.unpack_from('<II', hdr, o)
    if cmd == 0x19 and hdr[o + 8:o + 14] == b'__TEXT':
        for k in range(struct.unpack_from('<I', hdr, o + 64)[0]):
            q = o + 72 + k * 80
            if hdr[q:q + 6] == b'__text':
                tx = struct.unpack_from('<QQ', hdr, q + 32)
    o += sz
print('trace text', hex(tx[0]), hex(tx[1]))
t = bytes(c.rd(tx[0], tx[1]))
page = {}
def sx(v, b): return v - (1 << b) if v & (1 << (b - 1)) else v
hits = []
for off in range(0, len(t), 4):
    w = struct.unpack_from('<I', t, off)[0]; va = tx[0] + off
    if w & 0x9f000000 == 0x90000000:
        page[w & 31] = (va & ~0xfff) + (sx(((w >> 29) & 3) | (((w >> 5) & 0x7ffff) << 2), 21) << 12)
    elif w & 0xffc00000 == 0x91000000 and ((w >> 5) & 31) in page:
        ad = page[(w >> 5) & 31] + ((w >> 10) & 0xfff)
        cs = c.cstr(ad)
        if cs and cs in ('Enable-Private-Data', 'Private', 'Public', 'DEFAULT-OPTIONS', 'Enable', 'Persist', 'Level', 'Enable-Oversize-Messages', 'Default-Privacy-Setting'):
            hits.append((va, cs))
print(hits)
for va, cs in hits:
    if cs == 'Enable-Private-Data':
        out = []
        for x in range(va - 0xa0, va + 0xc0, 4):
            w = struct.unpack_from('<I', t, x - tx[0])[0]
            if w & 0xfc000000 == 0x94000000:
                out.append(f'{x:#x} bl {x + sx(w & 0x3ffffff, 26) * 4:#x}')
            elif w & 0xff000000 in (0xb4000000, 0xb5000000, 0x34000000, 0x35000000):
                out.append(f'{x:#x} cb')
        print(cs, out[:20])
        print(hex(va))
