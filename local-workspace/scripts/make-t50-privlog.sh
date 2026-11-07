#!/bin/bash
# A copy of a t50 volume whose log messages keep their private arguments for the Poster and Chrono subsystems, so the store's real error can be read.
# The kernel's third overlay moves to /System/Library/Preferences/Logging/Subsystems (a union mount: the sealed files stay visible). Log content only: no service
# changes behaviour. Files land in /private/var/ngpu/wallpaper on Data, as the wallpaper test's did. Temporary boot only.
# Usage: make-t50-privlog.sh <dir holding vol.img> <work dir>
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
SRC=$1; W=$2; S=/mnt/e/DSH-Fuxi/dump/wsl
[ -f /root/fuxi/logging-prefs/System/Library/Preferences/Logging/Subsystems/com.apple.chrono.plist ]
rm -rf "$W"; mkdir -p "$W"; cp "$SRC/vol.img" "$W/vol.img"; cd "$W"
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml > toml.txt
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-orig.bin
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.orig
python3 -I - <<'EOF'
import os, plistlib, struct, zlib
base = '/root/fuxi/logging-prefs/System/Library/Preferences/Logging/Subsystems/'
PUBLIC = {'Default-Privacy-Setting': 'Public', 'Enable-Private-Data': True}
VERBOSE = dict(PUBLIC, Level={'Enable': 'Debug', 'Persist': 'Debug'})
files = []
for name, opts in (('com.apple.PosterBoard', VERBOSE), ('com.apple.posterboard', VERBOSE), ('com.apple.PosterKit', VERBOSE), ('com.apple.PosterBoardUIServices', VERBOSE),
                   ('com.apple.posterboardservices', VERBOSE), ('com.apple.posterkit.provider', VERBOSE),
                   ('com.apple.chrono', PUBLIC), ('com.apple.chronod', PUBLIC), ('com.apple.chronocore', PUBLIC), ('com.apple.chronoservices', PUBLIC)):
    p = base + name + '.plist'
    d = plistlib.load(open(p, 'rb')) if os.path.exists(p) else {}
    d.setdefault('DEFAULT-OPTIONS', {}).update(opts)
    files.append((name + '.plist', plistlib.dumps(d, fmt=plistlib.FMT_BINARY)))
b = open('addon-orig.bin', 'rb').read()
assert b[:8] == b'NGPUADD2'
count = struct.unpack_from('<I', b, 8)[0]
at, kept, seen = 24, b'', 0
for _ in range(count):
    start = at
    nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at); at += 24
    name = b[at:at + nl - 1].decode()
    at += (nl + 7) // 8 * 8 + (packed + 7) // 8 * 8
    assert not name.startswith('wallpaper/'), name
    if 'filler' in name: continue
    kept += b[start:at]; seen += 1
assert at == len(b)
for n, data in files:
    name = ('wallpaper/' + n).encode() + b'\0'
    p = zlib.compress(data, 9)
    kept += struct.pack('<IIQQ', len(name), 0o644, len(data), len(p)) + name + bytes(-len(name) % 8) + p + bytes(-len(p) % 8)
open('addon-nofill.bin', 'wb').write(b'NGPUADD2' + struct.pack('<IIQ', seen + len(files), 0, 24 + len(kept)) + kept)
print('kept', seen, 'added', len(files))
d = bytearray(open('kernel.orig', 'rb').read())
P = b'/Library/Wallpaper/Collections/iPadOS_17~ipad.wallpaperCollection/Wallpapers/7570.iPadOS_17_Flat-1024w-1366h@2x~ipad.wallpaper/7570.iPadOS_17_Flat_Background-1024w-1366h@2x~ipad.ca'
L = b'/System/Library/Preferences/Logging/Subsystems'
for old, new in ((P, L), (P + b'/assets/J120.HEIC', L + b'/com.apple.SpringBoard.plist'), (P + b'/J120.png', L + b'/com.apple.PosterBoard.plist')):
    s = b'\0' + old + b'\0'
    assert d.count(s) == 1, old[-20:]
    i = d.find(s) + 1
    d[i:i + len(old)] = new + bytes(len(old) - len(new))
open('kernel.macho', 'wb').write(d)
EOF
python3 -I $S/fit-addon.py addon-orig.bin addon-nofill.bin addon-new.bin
[ "$(stat -c%s addon-new.bin)" = "$(stat -c%s addon-orig.bin)" ]
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-new.bin >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho >/dev/null
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-new.bin
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.back; cmp kernel.back kernel.macho; rm -f kernel.back
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | cmp - toml.txt
echo "kernel bytes changed: $(cmp -l kernel.orig kernel.macho | wc -l)"
rm -f kernel.orig
