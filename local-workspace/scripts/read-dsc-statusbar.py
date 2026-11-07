#!/usr/bin/env python3
"""Read only: the status bar's provider selection in the 21H461 cache. Finds methods through the ObjC class data, then disassembles them with selector stubs named.
Usage: read-dsc-statusbar.py <dsc dir>"""
import mmap, re, struct, subprocess, sys
from pathlib import Path
D = Path(sys.argv[1])
maps, files, images = [], {}, []
for f in sorted(D.glob('dyld_shared_cache_arm64*')):
    if f.stat().st_size == 0 or 'ResourceFork' in f.name or 'decmpfs' in f.name:
        continue
    fh = f.open('rb'); m = mmap.mmap(fh.fileno(), 0, access=mmap.ACCESS_READ)
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
def unp(q): return q & 0xfffffffff if q & 0xfffffffff >= 0x180000000 else (q & 0xfffffffff) + 0x180000000
def u64(va):
    b = rd(va, 8); return struct.unpack('<Q', b)[0] if b else 0
def cstr(va):
    b = rd(va, 300)
    if not b: return None
    b = b.split(b'\0')[0]
    return b.decode('latin1') if b and all(32 <= c < 127 for c in b) else None
def ptrstr(va):
    q = u64(va)
    return cstr(unp(q)) if q else None
def stub(va):
    code = rd(va, 12)
    if not code: return None
    a, b = struct.unpack_from('<II', code)
    if a & 0x9f000000 != 0x90000000: return None
    imm = ((a >> 29) & 3) | (((a >> 5) & 0x7ffff) << 2)
    if imm & (1 << 20): imm -= 1 << 21
    page = (va & ~0xfff) + (imm << 12)
    if b & 0xffc00000 == 0xf9400000: return ptrstr(page + (((b >> 10) & 0xfff) << 3))
    if b & 0xff800000 == 0x91000000: return cstr(page + ((b >> 10) & 0xfff))
def sections(base):
    hdr = rd(base, 0x8000); n = struct.unpack_from('<I', hdr, 16)[0]; at, out = 32, {}
    for _ in range(n):
        cmd, size = struct.unpack_from('<II', hdr, at)
        if cmd == 0x19:
            for i in range(struct.unpack_from('<I', hdr, at + 64)[0]):
                s = at + 72 + i * 80
                out[hdr[s:s + 16].rstrip(b'\0').decode()] = struct.unpack_from('<QQ', hdr, s + 32)
        at += size
    return out
SELBASE = [None]
def methods(ml):
    """(name, imp) of a relative method list. Direct selector offsets share one base; found from the first list that gives valid names."""
    if not ml: return []
    h = rd(ml, 8)
    if not h: return []
    flags, cnt = struct.unpack('<II', h)
    out = []
    if not flags & 0x80000000:
        return out
    ents = [struct.unpack_from('<iii', rd(ml + 8 + i * 12, 12)) for i in range(cnt)]
    if flags & 0x40000000:
        if SELBASE[0] is None and ents:
            for cand in (0x180000000 + k * 0x1000 for k in range(0, 0x80000)):
                break
        base = SELBASE[0]
        for i, (n, t, imp) in enumerate(ents):
            out.append((cstr(base + n) if base else None, ml + 8 + i * 12 + 8 + imp))
    else:
        for i, (n, t, imp) in enumerate(ents):
            at = ml + 8 + i * 12
            out.append((ptrstr(at + n), at + 8 + imp))
    return out
def find_selbase():
    """Find the selector base from a known pair: search the cache for a selector and test its offset in a class's list."""
    return None
def classes(base):
    s = sections(base); a, n = s['__objc_classlist']; out = {}
    data = rd(a, n)
    for i in range(0, n, 8):
        c = unp(struct.unpack_from('<Q', data, i)[0])
        ro = unp(u64(c + 32)) & ~7
        if not rd(ro, 72): continue
        name = cstr(unp(u64(ro + 24)))
        out[name] = (c, ro)
    return out
def strip_ml(ro): return unp(u64(ro + 32)) if u64(ro + 32) else 0
def locate_selbase(cl):
    # A direct list's names are offsets from one base. Take any list and find the base that makes every name a printable selector.
    target = b'\0init\0'
    for nm, (c, ro) in cl.items():
        ml = strip_ml(ro)
        if not ml: continue
        h = rd(ml, 8)
        if not h: continue
        fl, cnt = struct.unpack('<II', h)
        if fl & 0xc0000000 == 0xc0000000 and 3 <= cnt < 60:
            ofs = [struct.unpack_from('<i', rd(ml + 8 + i * 12, 4))[0] for i in range(cnt)]
            for a, s, o, name in maps:
                pass
            return ofs
    return None
ui = [x for x in images if x[1].endswith('/UIKitCore.framework/UIKitCore')][0][0]
st = [x for x in images if x[1].endswith('/SystemStatusUI.framework/SystemStatusUI')]
print('UIKitCore', hex(ui), 'SystemStatusUI', [hex(x[0]) for x in st])
ucl = classes(ui)
print('classes', len(ucl), '_UIStatusBar' in ucl)
c, ro = ucl['_UIStatusBar']; ml = strip_ml(ro); fl, cnt = struct.unpack('<II', rd(ml, 8))
print('method list flags', hex(fl), 'count', cnt)
if fl & 0x40000000:
    # The selector strings: find "_prepareVisualProviderIfNeeded" in the mapped cache and match it with an offset in this list.
    ofs = [struct.unpack_from('<i', rd(ml + 8 + i * 12, 4))[0] for i in range(cnt)]
    hits = []
    for a, s, o, name in maps:
        mm = files[name]
        p = mm.find(b'\0_prepareVisualProviderIfNeeded\0', o, o + s)
        if p >= 0: hits.append(a + p - o + 1)
    print('selector strings', [hex(h) for h in hits])
    for h in hits:
        for v in ofs:
            b = h - v
            if sum(1 for w in ofs if cstr(b + w)) == cnt:
                SELBASE[0] = b; break
        if SELBASE[0]: break
    print('selector base', hex(SELBASE[0] or 0))
def meth(cl, name, meta=False):
    if name not in cl: return {}
    c, ro = cl[name]
    if meta:
        mc = unp(u64(c)); ro = unp(u64(mc + 32)) & ~7
    return {k: v for k, v in methods(strip_ml(ro)) if k}
def dump(start, n, title):
    print('==', title, hex(start))
    data = rd(start, n)
    Path('/tmp/sbf.bin').write_bytes(data)
    out = subprocess.run(['aarch64-linux-gnu-objdump', '-D', '-b', 'binary', '-m', 'aarch64', f'--adjust-vma={start:#x}', '/tmp/sbf.bin'], capture_output=True, text=True).stdout
    regs = {}
    for line in out.splitlines():
        m = re.match(r'\s*([0-9a-f]+):\s+([0-9a-f]{8})\s+(.*)', line)
        if not m: continue
        va, ins, text = int(m[1], 16), int(m[2], 16), re.sub(r'\s+', ' ', m[3])
        note = ''
        if ins & 0x9f000000 == 0x90000000:
            imm = ((ins >> 29) & 3) | (((ins >> 5) & 0x7ffff) << 2)
            if imm & (1 << 20): imm -= 1 << 21
            regs[ins & 31] = (va & ~0xfff) + (imm << 12)
        elif ins & 0xff800000 == 0x91000000 and (ins >> 5) & 31 in regs:
            t = regs[(ins >> 5) & 31] + ((ins >> 10) & 0xfff)
            c = cstr(t) or ptrstr(t + 16)
            note = f'  ; {c!r}' if c else ''
        elif ins & 0xffc00000 == 0xf9400000 and (ins >> 5) & 31 in regs:
            t = regs[(ins >> 5) & 31] + (((ins >> 10) & 0xfff) << 3)
            q = u64(t)
            if q:
                x = unp(q)
                c = cstr(unp(u64(unp(u64(x + 32)) & ~7) + 24)) if rd(x + 32, 8) else None
                note = f'  ; class {c}' if c else ''
        elif ins & 0xfc000000 in (0x94000000, 0x14000000):
            imm = ins & 0x3ffffff
            if imm & (1 << 25): imm -= 1 << 26
            c = stub(va + imm * 4)
            note = f'  ; [{c}]' if c else ''
        print(f'{va:#x} {text}{note}')
        if text.startswith('ret') and va > start + 0x20: break
if len(sys.argv) > 2 and sys.argv[2] == 'cache':
    for title, start, n, page, off in (('UIKit', 0x18a10c360, 0x500, 0x1f48d7000, 472), ('STUI', 0x1cf36c2fc, 0x500, 0x1f5abb000, 1792)):
        data = rd(start, n); pgs = {}
        print('==', title, 'slot', hex(page + off), 'bytes now', rd(page + off, 8).hex())
        for i in range(0, n, 4):
            ins = struct.unpack_from('<I', data, i)[0]; va = start + i
            if ins & 0x9f000000 == 0x90000000:
                imm = ((ins >> 29) & 3) | (((ins >> 5) & 0x7ffff) << 2)
                if imm & (1 << 20): imm -= 1 << 21
                pgs[ins & 31] = (va & ~0xfff) + (imm << 12)
            elif ins & 0xffc00000 in (0xf9000000, 0xf9400000):
                base = (ins >> 5) & 31
                if pgs.get(base) == page and ((ins >> 10) & 0xfff) * 8 == off:
                    print(hex(va), 'store' if ins & 0xffc00000 == 0xf9000000 else 'load', 'x%d' % (ins & 31))
        # Each store's surroundings
        for i in range(0, n, 4):
            ins = struct.unpack_from('<I', data, i)[0]
            if ins & 0xffc00000 == 0xf9000000 and ((ins >> 10) & 0xfff) * 8 == off:
                dump(start + i - 0x28, 0x40, title + ' around the store')
    scl = classes(st[0][0])
    for cl, nm, src in (('STUIStatusBar', '_visualProvider', scl), ('_UIStatusBar', '_visualProvider', ucl)):
        c, ro = src[cl]; iv = unp(u64(ro + 48)) if u64(ro + 48) else 0
        if iv:
            es, cnt = struct.unpack('<II', rd(iv, 8))
            print(cl, 'ivars', [cstr(unp(u64(iv + 8 + i * es + 8))) for i in range(cnt)][:30])
    for cl, src in (('_UIStatusBarVisualProvider_DynamicSplitMedium', ucl), ('STUIStatusBarVisualProvider_DynamicSplitMedium', scl), ('_UIStatusBarVisualProvider_DynamicSplit', ucl), ('STUIStatusBarVisualProvider_DynamicSplit', scl)):
        print(cl, [k for k in meth(src, cl, True) if 'cale' in k or 'nativeDisplay' in k or 'height' in k or 'Supported' in k or 'ubclass' in k])
    sys.exit(0)
if len(sys.argv) > 2 and sys.argv[2] == 'key':
    dump(0x18a2bfb8c, 0xa0, 'UIKit: what the key is read from')
    scl = classes(st[0][0]); im = meth(scl, 'STUIStatusBar')
    p = im['_prepareVisualProviderIfNeeded']
    b = rd(p + 0x8c, 0x30)
    for i in range(0, 0x30, 4):
        ins = struct.unpack_from('<I', b, i)[0]
        if ins & 0xfc000000 == 0x94000000:
            imm = ins & 0x3ffffff
            if imm & (1 << 25): imm -= 1 << 26
            t = p + 0x8c + i + imm * 4
            first = struct.unpack('<I', rd(t, 4))[0]
            print('call', hex(p + 0x8c + i), '->', hex(t), hex(first), stub(t))
            if first & 0xff0003ff == 0xd10003ff:   # sub sp, sp, #n: a real function
                dump(t, 0xc0, 'STUI selector')
    for a, s, o, name in maps:
        mm = files[name]; at = o
        while True:
            q = mm.find(b'\0UIStatusBarVisualProviderClassName\0', at, o + s)
            if q < 0: break
            print('key string at', hex(a + q - o + 1), name.split('.')[-1])
            at = q + 8
    # All UIKit defaults accessors, for the name of the suite.
    for w in (b'com.apple.UIKit', b'com.apple.uikit'):
        for a, s, o, name in maps:
            q = files[name].find(b'\0' + w + b'\0', o, o + s)
            if q >= 0: print(w.decode(), hex(a + q - o + 1))
    sys.exit(0)
if len(sys.argv) > 2 and sys.argv[2] == 'sel':
    dump(0x18a10c360, 0x180, 'UIKit selector')
    scl = classes(st[0][0]); im = meth(scl, 'STUIStatusBar')
    print('STUI instance', [k for k in im if 'isual' in k])
    p = im['_prepareVisualProviderIfNeeded']; b = rd(p, 0x90)
    dump(p, 0x90, 'STUI prepare, start')
    for i in range(0, 0x90, 4):
        ins = struct.unpack_from('<I', b, i)[0]
        if ins & 0xfc000000 == 0x94000000 and i > 0x20:
            imm = ins & 0x3ffffff
            if imm & (1 << 25): imm -= 1 << 26
            t = p + i + imm * 4
            if not stub(t) and rd(t, 4) and struct.unpack('<I', rd(t, 4))[0] & 0xff0003ff != 0xd503201f and t < st[0][0] + 0x400000 and t > st[0][0]:
                dump(t, 0x180, 'STUI callee')
    mm = meth(scl, 'STUIStatusBarVisualProvider_iOS', True)
    print(sorted(mm))
    if 'visualProviderSubclassForScreen:visualProviderInfo:' in mm: dump(mm['visualProviderSubclassForScreen:visualProviderInfo:'], 0xc0, 'STUI iOS factory')
    for cls in ('STUIStatusBarVisualProvider_DynamicSplitMedium', 'STUIStatusBarVisualProvider_Split1080', '_UIStatusBarVisualProvider_DynamicSplitMedium', '_UIStatusBarVisualProvider_Split1080'):
        src = scl if cls.startswith('STUI') else ucl
        print(cls, sorted(meth(src, cls, True))[:12], [k for k in meth(src, cls) if 'upported' in k][:4])
    sys.exit(0)
if len(sys.argv) > 2 and sys.argv[2] == 'layout':
    scl = classes(st[0][0])
    def fname(q):
        return cstr(unp(u64(unp(u64(q + 32)) & ~7) + 24))
    for prefix, src in (('_UIStatusBarVisualProvider_', ucl), ('STUIStatusBarVisualProvider_', scl)):
        name = prefix + 'DynamicSplitMedium'
        while name in src and name != 'NSObject':
            print('==', name, 'class', sorted(meth(src, name, True)))
            print('   instance', sorted(meth(src, name)))
            c = src[name][0]; sup = unp(u64(c + 8)); name = fname(sup)
    def dbl(va): return struct.unpack('<d', rd(va, 8))[0]
    for name in ('_UIStatusBarVisualProvider_DynamicSplitMedium', '_UIStatusBarVisualProvider_DynamicSplit', '_UIStatusBarVisualProvider_Split'):
        c = ucl[name][0]; sup = unp(u64(c + 8))
        print('==', name, 'super at', hex(sup), 'name', fname(sup))
        print('   class', sorted(meth(ucl, name, True)))
        print('   instance', sorted(meth(ucl, name)))
    print('DynamicSplit height', dbl(0x18b341000 + 2368))
    if len(sys.argv) > 3:
        im = meth(ucl, '_UIStatusBarVisualProvider_DynamicSplit')
        for k in sys.argv[3].split(','):
            dump(im[k], 0x180, k)
        sys.exit(0)
    for name in ('_UIStatusBarVisualProvider_DynamicSplit', '_UIStatusBarVisualProvider_DynamicSplitMedium'):
        for k, v in sorted(meth(ucl, name).items()):
            if re.search('ffset|nsets?$|ensor|eight|aseline|enter|setup|orderedDisplay', k):
                dump(v, 0x500 if 'setup' in k else 0x40, f'-[{name} {k}]')
    dump(0x18a10c8a8, 0xa0, 'after +height: edge info function')
    sys.exit(0)
sm = meth(ucl, '_UIStatusBar')
print('instance', [k for k in sm if 'isual' in k])
for k in ('_prepareVisualProviderIfNeeded',):
    if k in sm: dump(sm[k], 0x300, '-[_UIStatusBar %s]' % k)
for cls in ('_UIStatusBarVisualProvider_iOS', '_UIStatusBarVisualProvider_Phone', '_UIStatusBarVisualProvider_Split', '_UIStatusBarVisualProvider_DynamicSplit', '_UIStatusBarVisualProvider_DynamicSplitMedium', '_UIStatusBarVisualProvider_Split1080'):
    c, ro = ucl.get(cls, (0, 0))
    sup = cstr(unp(u64(unp(u64(unp(u64(c + 8)) + 32)) & ~7) + 24)) if c else None
    mm = meth(ucl, cls, True)
    print(cls, 'super', sup, 'class methods', sorted(mm)[:14])
    if 'visualProviderSubclassForScreen:visualProviderInfo:' in mm and cls.endswith(('_iOS', '_Phone', 'DynamicSplit')):
        dump(mm['visualProviderSubclassForScreen:visualProviderInfo:'], 0x1c0, '+[%s visualProviderSubclassForScreen:visualProviderInfo:]' % cls)
if st:
    scl = classes(st[0][0]); print('STUI classes', len(scl))
    im = meth(scl, 'STUIStatusBar')
    print('STUI instance', [k for k in im if 'isual' in k])
    if '_prepareVisualProviderIfNeeded' in im: dump(im['_prepareVisualProviderIfNeeded'], 0x300, '-[STUIStatusBar _prepareVisualProviderIfNeeded]')
    for cls in ('STUIStatusBarVisualProvider_iOS', 'STUIStatusBarVisualProvider_DynamicSplitMedium'):
        print(cls, sorted(meth(scl, cls, True))[:14])
