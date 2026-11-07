#!/usr/bin/env python3
# Read-only: header of a boot image, and where the known markers sit in it.
import struct, sys, re, hashlib
p = sys.argv[1]
d = open(p, 'rb').read()
print('size', len(d), 'magic', d[:8])
if d[:8] == b'ANDROID!':
    v = struct.unpack_from('<I', d, 40)[0]
    print('header version', v)
    if v >= 3:
        ks, rs, osv, hs = struct.unpack_from('<IIII', d, 8)
        print('kernel', hex(ks), 'ramdisk', hex(rs), 'os_version', hex(osv), 'header', hs)
        print('cmdline', d[44:44 + 1536].split(b'\0')[0][:400])
        page = 4096
        kern = d[page:page + ks]
        print('kernel sha', hashlib.sha256(kern).hexdigest()[:16], 'head', kern[:16].hex())
        open(sys.argv[2], 'wb').write(kern)
    else:
        ks, ka, rs, ra, ss, sa, ta, ps = struct.unpack_from('<IIIIIIII', d, 8)
        print('kernel', hex(ks), 'ramdisk', hex(rs), 'second', hex(ss), 'page', ps)
        print('cmdline', d[64:64 + 512].split(b'\0')[0][:400])
        kern = d[ps:ps + ks]
        print('kernel sha', hashlib.sha256(kern).hexdigest()[:16], 'head', kern[:16].hex())
        open(sys.argv[2], 'wb').write(kern)
for name, pat in [('feedface64', b'\xcf\xfa\xed\xfe'), ('Darwin ver', rb'Darwin Kernel Version [^\0]{0,120}'), ('gz', b'\x1f\x8b\x08'), ('lzfse', b'bvx2'), ('lz4 frame', b'\x04\x22\x4d\x18'), ('IM4P', b'IM4P'), ('zstd', b'\x28\xb5\x2f\xfd'), ('UEFI FV', b'_FVH'), ('dtb', b'\xd0\x0d\xfe\xed')]:
    hits = [m.start() for m in re.finditer(pat, d)]
    print(f'{name}: {len(hits)}', [hex(h) for h in hits[:8]])
for m in list(re.finditer(rb'Darwin Kernel Version [^\0]{0,120}', d))[:3]:
    print(m.group()[:150])
for key in [b'sheng', b'SXNU1R', b'PE_halt_restart', b'control_hook', b'usbsxnu', b'qud', b'QUD', b'unixnu', b'UniXNU', b'iPhone15,2', b'iPad', b'github', b'REBOOT', b'SCREENSHOT', b'SCREEN', b'dwc3', b'DWC3', b'tinyusb', b'mass_storage']:
    hits = [m.start() for m in re.finditer(key, d)]
    print(key.decode(), len(hits), [hex(h) for h in hits[:4]])
