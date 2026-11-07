# Read-only: subsystem strings next to os_log_create in the libraries that matter. Run from dump/wsl with -I.
import importlib.util, re, sys, bisect
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
import struct
imgs = sorted(c.images); addrs = [a for a, _ in imgs]
want = ('/PosterBoard.framework/PosterBoard', '/PosterKit.framework/PosterKit', '/PosterBoardUIServices.framework/PosterBoardUIServices', '/PosterUIFoundation.framework/PosterUIFoundation', '/ChronoServices.framework/ChronoServices', '/ChronoCore.framework/ChronoCore', '/WidgetRenderer.framework/WidgetRenderer', '/ChronoKit.framework/ChronoKit')
for i, (a, nm) in enumerate(imgs):
    if not nm.endswith(want): continue
    hdr = bytes(c.rd(a, 0x8000)); o = 32; found = set()
    for _ in range(struct.unpack_from('<I', hdr, 16)[0]):
        cmd, sz = struct.unpack_from('<II', hdr, o)
        if cmd == 0x19:
            for k in range(struct.unpack_from('<I', hdr, o + 64)[0]):
                q = o + 72 + k * 80
                if hdr[q:q + 16].rstrip(b'\0') == b'__cstring':
                    ad, n = struct.unpack_from('<QQ', hdr, q + 32)
                    for s in bytes(c.rd(ad, n)).split(b'\0'):
                        if re.fullmatch(rb'com\.apple\.[A-Za-z0-9]+(\.[A-Za-z0-9]+)?', s) and len(s) < 34: found.add(s.decode())
        o += sz
    print(nm.split('/')[-1], sorted(found)[:18])
