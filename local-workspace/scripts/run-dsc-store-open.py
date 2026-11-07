# Read-only: call lists of the PosterBoard functions around the store's database open. Run from dump/wsl with -I; arguments are hex addresses.
import importlib.util, struct, sys
args = sys.argv[1:]
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
tx, n = c.sec['__text']; t = c.rd(tx, n)
PAC = 0xd503237f
def w(va): return struct.unpack_from('<I', t, va - tx)[0]
def sx(v, b): return v - (1 << b) if v & (1 << (b - 1)) else v
def func(va):
    a = va & ~3
    while a > tx and w(a) != PAC: a -= 4
    b = a + 4
    while b < tx + n and w(b) != PAC: b += 4
    return a, b
for arg in args:
    x = int(arg, 16); a = x - 0x1a0; b = x + 0x260
    print(f'== func {a:#x}..{b:#x} ({(b - a) // 4} ins)')
    page = {}
    for va in range(a, b, 4):
        i = w(va); out = None
        if i & 0xfc000000 == 0x94000000:
            nm = c.stub(va + sx(i & 0x3ffffff, 26) * 4)
            out = ('bl ' + nm[:100]) if nm and len(nm) > 2 else None
        elif i & 0x9f000000 == 0x90000000:
            imm = sx(((i >> 29) & 3) | (((i >> 5) & 0x7ffff) << 2), 21)
            page[i & 31] = (va & ~0xfff) + (imm << 12)
        elif i & 0xffc00000 == 0x91000000 and ((i >> 5) & 31) in page:
            ad = page[(i >> 5) & 31] + ((i >> 10) & 0xfff)
            try:
                s = c.ptrstr(ad) or c.cstr(ad)
            except Exception:
                s = None
            if s and len(s) > 2: out = f'str {s[:110]!r}'
        elif i & 0x7f000000 in (0x34000000, 0x35000000, 0x36000000, 0x37000000) or i & 0xff000010 == 0x54000000:
            pass
        elif i == 0xd65fcfff or i == 0xd65f03c0:
            out = 'ret'
        if out: print(f'  {va:#x} {out}')
