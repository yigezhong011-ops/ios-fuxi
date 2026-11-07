#!/bin/bash
# t50-mine-gpu-fix plus a phone wallpaper catalog: Bokeh (procedural, no HEIC, its collection names iPhone) offered through the kernel's third overlay mount.
# Two changes only: the overlay's files in the GPU addon (same addon size, filler shrinks) and the mount's three path strings in the kernel.
# The mount point moves to /Library/Wallpaper; the overlay's Collections directory shadows the sealed one. Temporary boot only; touches no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-gpu-wall; I=$E/ux-out/fuxi/userdata/userdata-root.img; OUT=$E/t50-mine-gpu-wall.img
[ ! -e "$OUT" ] || { echo "refuse to overwrite $OUT"; exit 1; }
rm -rf "$W"; mkdir -p "$W/root"
cp /root/fuxi/gpu-new-t50-mine/vol.img "$W/vol.img"
cd "$W"
echo "== kernel limits on addon entries"
grep -n -E 'count *[>=]|name_bytes *[>=<]|char path\[|bytes *[>]' $E/unixnu-build/fuxi/patches/xnu/zzy-native-gpu-addon-mount.patch | cut -c1-130 | head -10
echo "== toml"; mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.txt; grep -n -i -E 'hash|sha|addon' toml.txt | cut -c1-120 | head; tr ' ' '\n' < toml.txt | grep -E 'sheng-staged|sheng-setup'
7z x -y -bd -oroot "$I" 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Info.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/WallpaperCollection.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Localizable.loctable' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/*/Wallpaper.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/*/Localizable.loctable' >/dev/null 2>&1
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-orig.bin
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.orig
python3 -I - <<'EOF'
import plistlib, struct, zlib
from pathlib import Path
src = Path('root/Library/Wallpaper')
BOKEH = 'D4894D14-DB0F-4D04-AB02-07C39C5E5466'
files = [
    ('DefaultWallpapers~iphone.plist', plistlib.dumps({'default': {'wallpaperIdentifier': 5010, 'collectionIdentifier': BOKEH}}, fmt=plistlib.FMT_BINARY)),
    ('Wallpapers~iphone.plist', plistlib.dumps([{'wallpaperType': 'Dynamic'}], fmt=plistlib.FMT_BINARY)),
    ('Collections/Collections~iphone.plist', plistlib.dumps({'order': [BOKEH]}, fmt=plistlib.FMT_BINARY)),
    ('Collections/Collections.plist', plistlib.dumps({'order': [BOKEH]}, fmt=plistlib.FMT_BINARY)),
]
for f in sorted((src / 'Collections/Bokeh.wallpaperCollection').rglob('*')):
    if f.is_file():
        files.append((f.relative_to(src).as_posix(), f.read_bytes()))
assert len([n for n, _ in files if n.endswith('/Wallpaper.plist')]) == 9
b = open('addon-orig.bin', 'rb').read()
assert b[:8] == b'NGPUADD2'
count = struct.unpack_from('<I', b, 8)[0]
at, kept, seen = 24, b'', 0
for _ in range(count):
    start = at
    nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at)
    at += 24
    name = b[at:at + nl - 1].decode()
    at += (nl + 7) // 8 * 8 + (packed + 7) // 8 * 8
    assert not name.startswith('wallpaper/')
    if 'filler' in name:
        continue
    kept += b[start:at]
    seen += 1
assert at == len(b)
for n, data in files:
    name = ('wallpaper/' + n).encode() + b'\0'
    assert len(name) < 150, n
    p = zlib.compress(data, 9)
    kept += struct.pack('<IIQQ', len(name), 0o644, len(data), len(p)) + name + bytes(-len(name) % 8) + p + bytes(-len(p) % 8)
open('addon-nofill.bin', 'wb').write(b'NGPUADD2' + struct.pack('<IIQ', seen + len(files), 0, 24 + len(kept)) + kept)
print('kept', seen, 'added', len(files), 'raw bytes', sum(len(d) for _, d in files))
d = bytearray(open('kernel.orig', 'rb').read())
P = b'/Library/Wallpaper/Collections/iPadOS_17~ipad.wallpaperCollection/Wallpapers/7570.iPadOS_17_Flat-1024w-1366h@2x~ipad.wallpaper/7570.iPadOS_17_Flat_Background-1024w-1366h@2x~ipad.ca'
for old, new in ((P, b'/Library/Wallpaper'),
                 (P + b'/assets/J120.HEIC', b'/Library/Wallpaper/DefaultWallpapers~ipad.plist'),
                 (P + b'/J120.png', b'/Library/Wallpaper/DefaultWallpapers~iphone.plist')):
    s = b'\0' + old + b'\0'
    assert d.count(s) == 1, old[-20:]
    i = d.find(s) + 1
    d[i:i + len(old)] = new + bytes(len(old) - len(new))
    print(hex(i), new.decode())
open('kernel.macho', 'wb').write(d)
EOF
python3 -I $S/fit-addon.py addon-orig.bin addon-nofill.bin addon-new.bin
[ "$(stat -c%s addon-new.bin)" = "$(stat -c%s addon-orig.bin)" ]
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-new.bin
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-new.bin
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.back; cmp kernel.back kernel.macho
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | cmp - toml.txt
python3 -I - <<'EOF'
import struct, zlib
b = open('addon-new.bin', 'rb').read()
o = open('addon-orig.bin', 'rb').read()
def rd(b):
    c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = {}
    for _ in range(c):
        nl, m, s, p = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        r[n] = (m, s, zlib.decompress(b[at:at + p])); at += (p + 7) // 8 * 8
    assert at == len(b)
    return r
a, c = rd(o), rd(b)
same = [n for n in a if 'filler' not in n and a[n] == c.get(n)]
print('addon entries old', len(a), 'new', len(c), 'unchanged', len(same))
print('removed', [n for n in a if n not in c]); print('added count', len([n for n in c if n not in a]))
for n in c:
    if n not in a and not n.endswith(('Wallpaper.plist', 'loctable')):
        print('  ', c[n][1], n)
EOF
cmp -l kernel.orig kernel.macho | wc -l
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img "$OUT"
python3 -I $S/compare-loaders.py "$OUT"
python3 -I - $E/t50-mine-gpu-fix.img "$OUT" <<'EOF'
import sys, zlib, struct
def body(p):
    d = open(p, 'rb').read(); k = struct.unpack_from('<I', d, 8)[0]; h = struct.unpack_from('<I', d, 20)[0]; st = (h + 4095) // 4096 * 4096
    return len(d), zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[st:st + k])
a, x = body(sys.argv[1]); b, y = body(sys.argv[2])
n = [i for i in range(0, min(len(x), len(y)), 4096) if x[i:i + 4096] != y[i:i + 4096]]
print('image bytes', a, b, 'inner', len(x), len(y), 'differing 4K pages', len(n))
EOF
sha256sum "$OUT" | cut -c1-16
