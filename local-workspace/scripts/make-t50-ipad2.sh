#!/bin/bash
# t50-auto-ipad2: t50-auto-ipad with the earlier work brought over to the iPad identity.
#  Wallpaper: the overlay gains the ~ipad catalogue names (iPadOS 17 art as JPEG under Bokeh 5010); the ~iphone names go, for room.
#  Apps: sheng-staged-apps=1 copies the stock apps into Data; the sheng-setup=1 unlink is pointed at com.apple.migration.plist so SystemAppMigrator runs.
# The migration part deletes that file on every boot, so this is a temp boot image, never a daily one. Writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/t50-ipad2
rm -rf "$W"; mkdir -p "$W"; cd "$W"; cp /root/fuxi/t50-ipad/vol.img vol.img
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-orig.bin
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.orig
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.orig
python3 -I - <<'EOF'
import plistlib, struct, zlib
BOKEH = 'D4894D14-DB0F-4D04-AB02-07C39C5E5466'
b = open('addon-orig.bin', 'rb').read()
assert b[:8] == b'NGPUADD2'
count = struct.unpack_from('<I', b, 8)[0]
at, kept, seen, names = 24, b'', 0, []
DROP = ('wallpaper/DefaultWallpapers~iphone.plist', 'wallpaper/Wallpapers~iphone.plist', 'wallpaper/Collections/Collections~iphone.plist')
for _ in range(count):
    start = at
    nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at); at += 24
    name = b[at:at + nl - 1].decode()
    at += (nl + 7) // 8 * 8 + (packed + 7) // 8 * 8
    names.append(name)
    if 'filler' in name or name in DROP: continue
    kept += b[start:at]; seen += 1
assert at == len(b)
for n in DROP: assert n in names, n
assert 'wallpaper/Collections/Bokeh.wallpaperCollection/WallpaperCollection.plist' in names
def bin(v): return plistlib.dumps(v, fmt=plistlib.FMT_BINARY)
def entry(n, data):
    name = ('wallpaper/' + n).encode() + b'\0'
    p = zlib.compress(data, 9)
    return struct.pack('<IIQQ', len(name), 0o644, len(data), len(p)) + name + bytes(-len(name) % 8) + p + bytes(-len(p) % 8)
files = [('DefaultWallpapers~ipad.plist', bin({'default': {'wallpaperIdentifier': 5010, 'collectionIdentifier': BOKEH}})),
         ('Wallpapers~ipad.plist', bin([{'wallpaperType': 'Dynamic'}])),
         ('Collections/Collections~ipad.plist', bin({'order': [BOKEH]}))]
for n, d in files:
    kept += entry(n, d)
open('addon-nofill.bin', 'wb').write(b'NGPUADD2' + struct.pack('<IIQ', seen + len(files), 0, 24 + len(kept)) + kept)
print('entries', seen + len(files), 'room', len(b) - 24 - len(kept))
d = bytearray(open('kernel.orig', 'rb').read())
P = b'/private/var/mobile/Library/Preferences/'
new = P + b'com.apple.migration.plist\0'
for name in (b'com.apple.purplebuddy.plist', b'com.apple.purplebuddy.notbackedup.plist'):
    s = b'\0' + P + name + b'\0'
    assert d.count(s) == 1, name
    i = d.find(s) + 1
    n = len(P) + len(name) + 1
    assert len(new) <= n
    d[i:i + n] = new + b'\0' * (n - len(new))
open('kernel.macho', 'wb').write(d)
t = open('toml.orig', 'rb').read()
assert t.count(b'sheng-setup=0') == 1
open('toml', 'wb').write(t.replace(b'sheng-setup=0', b'sheng-setup=1'))
EOF
python3 -I $S/fit-addon.py addon-orig.bin addon-nofill.bin addon-new.bin
[ "$(stat -c%s addon-new.bin)" = "$(stat -c%s addon-orig.bin)" ]
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-new.bin >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/unixnu.toml toml >/dev/null
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-new.bin
echo "kernel bytes changed: $(cmp -l kernel.orig kernel.macho | wc -l)"
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
EXTRA_ARGS='sheng-staged-apps=1' bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-ipad2
mtype -i /root/fuxi/auto-t50-auto-ipad2/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -o -E 'offline-legacy-unit-scale=[0-9]|sheng-setup=[0-9]|sheng-data-persist=[0-9]|sheng-autoreset=[0-9]+|sheng-staged-apps=[0-9]' | tr '\n' ' '; echo
