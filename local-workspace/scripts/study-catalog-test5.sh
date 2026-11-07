#!/bin/bash
# The two top-level wallpaper plists, the running addon's file list and the Bokeh tree size. Read-only apart from /root/fuxi/cat-test.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; W=/root/fuxi/cat-test; V=/root/fuxi/gpu-new-t50-mine/vol.img; L=/mnt/e/DSH-Fuxi/dump/root-peek/list.txt
export MTOOLS_SKIP_CHECK=1
cd $W || exit 1
7z x -y -bd -owall "$I" 'Library/Wallpaper/DefaultWallpapers~ipad.plist' 'Library/Wallpaper/Wallpapers~ipad.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/*/Wallpaper.plist' >/dev/null 2>&1
mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-orig.bin
sha256sum addon-orig.bin | cut -c1-16
python3 -I - <<'EOF'
import plistlib, struct, zlib
from pathlib import Path
for n in ('DefaultWallpapers~ipad.plist', 'Wallpapers~ipad.plist'):
    print('--', n, plistlib.loads(Path('wall/Library/Wallpaper', n).read_bytes()))
for f in sorted(Path('wall/Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers').rglob('Wallpaper.plist')):
    p = plistlib.loads(f.read_bytes())
    print(f.parent.name, f.stat().st_size, p.get('identifier'), p.get('logicalScreenClass'), p.get('productTypes'), list(p['assets']))
b = open('addon-orig.bin', 'rb').read()
print(b[:8], len(b))
count = struct.unpack_from('<I', b, 8)[0]
at = 24
for _ in range(count):
    nl, mode, size, packed = struct.unpack_from('<IIQQ', b, at)
    at += 24
    name = b[at:at + nl - 1].decode()
    at += (nl + 7) // 8 * 8 + (packed + 7) // 8 * 8
    if not name.startswith('addons/NativeAdrenoMetal.bundle/') or size > 200000:
        print(f'{mode:o} {size:>9} {packed:>9} {name}')
EOF
echo "== other users of the wallpaper plists"
cd /mnt/e/DSH-Fuxi/dump/root-peek/dsc && for f in dyld_shared_cache_arm64*; do case "$f" in *.symbols|*.map) ;; *) LC_ALL=C grep -a -o -E '[ -~]{0,60}(DefaultWallpapers|Wallpapers~|"Wallpapers"|Wallpapers\.plist)[ -~]{0,50}' "$f" 2>/dev/null ;; esac; done | sort | uniq -c | sort -rn | cut -c1-140 | head -12
