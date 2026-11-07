# Read-only: which image holds Enable-Private-Data, and which functions read it. Run from dump/wsl with -I.
import importlib.util, re, struct, sys, bisect
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
imgs = sorted(c.images); addrs = [a for a, _ in imgs]
def owner(va):
    i = bisect.bisect_right(addrs, va) - 1
    return imgs[i][1] if i >= 0 else '?'
targets = [b'Enable-Private-Data', b'com.apple.system.logging', b'Enable-Logging']
m11 = c.files['dyld_shared_cache_arm64.11']
for t in targets:
    pos = [x.start() for x in re.finditer(re.escape(t), m11)][:6]
    for p in pos:
        for a, s, o, name in c.maps:
            if name == 'dyld_shared_cache_arm64.11' and o <= p < o + s:
                va = a + p - o
                print(t.decode(), hex(va), owner(va), repr(bytes(m11[p - 40:p + 60]).split(b'\0')[1:3]))
for p in (b'/Library/Preferences/Logging',):
    for name, m in c.files.items():
        for x in list(re.finditer(re.escape(p), m))[:12]:
            q = x.start()
            b = m.rfind(b'\0', 0, q) + 1; e = m.find(b'\0', q)
            s = bytes(m[b:e])
            if len(s) < 120:
                for a, sz, o, nm in c.maps:
                    if nm == name and o <= b < o + sz:
                        print(name[-3:], hex(a + b - o), owner(a + b - o).split('/')[-1], s.decode('latin1'))
