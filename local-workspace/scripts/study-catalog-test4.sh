#!/bin/bash
# Read the wallpaper catalogs and how WallpaperKit names them. Read-only apart from /root/fuxi/cat-test.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; W=/root/fuxi/cat-test; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $W || exit 1
L=/mnt/e/DSH-Fuxi/dump/root-peek/list.txt
grep -a -E 'Library/Wallpaper/[^/]+$' $L | awk '{print $4, $NF}' | cut -c1-100
rm -rf wall; mkdir wall
7z x -y -bd -owall "$I" 'Library/Wallpaper/Collections/Collections~ipad.plist' 'Library/Wallpaper/Collections/*/WallpaperCollection.plist' 'Library/Wallpaper/Collections/*/Info.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/5010.Multicolored.wallpaper/Wallpaper.plist' 'Library/Wallpaper/Collections/Stripe.wallpaperCollection/Wallpapers/7365.Stripe_Green.wallpaper/Wallpaper.plist' 'Library/Wallpaper/Collections/iPadOS_17~ipad.wallpaperCollection/Wallpapers/7570.iPadOS_17_Flat-1024w-1366h@2x~ipad.wallpaper/Wallpaper.plist' 2>&1 | tail -2 | cut -c1-110
python3 -I - <<'EOF'
import plistlib
from pathlib import Path
for f in sorted(Path('wall').rglob('*.plist')):
    b = f.read_bytes()
    print('--', str(f).replace('wall/Library/Wallpaper/Collections/', ''), len(b), b[:6])
    try:
        print('  ', str(plistlib.loads(b))[:900])
    except Exception as e:
        print('   parse', e)
EOF
echo "== Collections strings near the lookup"
cd "$D" && for f in dyld_shared_cache_arm64*; do case "$f" in *.symbols|*.map) ;; *) LC_ALL=C grep -a -o -E '[ -~]{0,70}(Collections\.plist|%@~%@|WKWallpaperBundleCollection|WallpaperBundleCollection|defaultCollection|_collectionsPlist|collectionsPlist)[ -~]{0,70}' "$f" 2>/dev/null ;; esac; done | sort | uniq -c | sort -rn | cut -c1-150 | head -24
LC_ALL=C grep -a -l 'WKWallpaperBundleCollection' dyld_shared_cache_arm64* 2>/dev/null | head -4
