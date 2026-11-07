# Read-only: how Chrono picks its image format, and which HEVC encoders the system knows. Run from dump/wsl with -I.
import importlib.util, re, struct, sys
sys.argv = ['x', '/mnt/e/DSH-Fuxi/dump/root-peek/dsc']
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
imgs = sorted(c.images)
def cstrs(nm_end):
    for i, (a, nm) in enumerate(imgs):
        if not nm.endswith(nm_end): continue
        hdr = bytes(c.rd(a, 0x8000)); o = 32; out = []
        for _ in range(struct.unpack_from('<I', hdr, 16)[0]):
            cmd, sz = struct.unpack_from('<II', hdr, o)
            if cmd == 0x19:
                for k in range(struct.unpack_from('<I', hdr, o + 64)[0]):
                    q = o + 72 + k * 80
                    if hdr[q:q + 16].rstrip(b'\0') in (b'__cstring', b'__oslogstring', b'__swift5_reflstr'):
                        ad, n = struct.unpack_from('<QQ', hdr, q + 32)
                        out += [s.decode('latin1') for s in bytes(c.rd(ad, n)).split(b'\0') if s]
            o += sz
        return out
    return []
for lib, pat in (('/ChronoServices.framework/ChronoServices', r'(?i)heic|hevc|imageio|jpeg|png|destination|archiv.*image|compress|lossy'),
                 ('/ChronoCore.framework/ChronoCore', r'(?i)heic|hevc|imageio|jpeg|png.*(fail|error)|destination|lossy'),
                 ('/WidgetRenderer.framework/WidgetRenderer', r'(?i)heic|hevc|imageio|destination|fail.*(archive|render)|placeholder.*fail'),
                 ('/VideoToolbox.framework/VideoToolbox', r'(?i)hevc.*encoder|videoencoder|AppleAVE|software.*hevc|hevc.*software|hvc1'),
                 ('/CMPhoto.framework/CMPhoto', r'(?i)hvc1|hevc|software|AppleAVE|encoder.*(fail|unavail|support)|canEncode|gestalt|H264|JPEG.*fallback')):
    s = cstrs(lib)
    hits = sorted({x for x in s if re.search(pat, x) and len(x) < 130})
    print('==', lib.split('/')[-1], len(s), 'strings,', len(hits), 'hits')
    for x in hits[:34]: print('  ', x)
