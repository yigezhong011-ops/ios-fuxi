#!/bin/bash
# Catalog text and the tools for a one-variable image. Read-only apart from /root/fuxi/cat-test.
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; W=/root/fuxi/cat-test; cd $W || exit 1
export MTOOLS_SKIP_CHECK=1
echo "== peek-root"; cut -c1-170 $S/peek-root.sh | head -24
echo "== apps script"; cut -c1-170 $S/make-t50-gpu-apps.sh | head -40
echo "== fit-addon tail"; sed -n '60,130p' $S/fit-addon.py | cut -c1-150
echo "== repack"; sed -n '1,14p' $S/repack-with-vol.py | cut -c1-150
echo "== os image candidates"
find /root/fuxi /mnt/e/DSH-Fuxi/ux-out /mnt/e/DSH-Fuxi/dump -maxdepth 4 -type f -size +1G 2>/dev/null | cut -c1-110 | head -14
OS=$(find /root/fuxi /mnt/e/DSH-Fuxi/ux-out /mnt/e/DSH-Fuxi/dump -maxdepth 4 -type f \( -name 'os.img' -o -name '*.dmg' \) -size +1G 2>/dev/null | head -1)
echo "OS=$OS"
if [ -n "$OS" ]; then
  mkdir -p wall; 7z x -y -bd -owall "$OS" 'Library/Wallpaper/Collections/Collections~ipad.plist' 'Library/Wallpaper/Collections/*/WallpaperCollection.plist' 'Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/5010.Multicolored.wallpaper/Wallpaper.plist' 'Library/Wallpaper/Collections/Stripe.wallpaperCollection/Wallpapers/7365.Stripe_Green.wallpaper/Wallpaper.plist' >/dev/null 2>&1
  python3 -I - <<'EOF'
import plistlib
from pathlib import Path
for f in sorted(Path('wall').rglob('*.plist')):
    b = f.read_bytes()
    print('--', str(f).replace('wall/Library/Wallpaper/Collections/', ''), len(b), b[:8])
    try:
        print(plistlib.loads(b))
    except Exception as e:
        print(' parse', e, b[:200])
EOF
fi
echo "== heic and caml under collections"
grep -a 'Library/Wallpaper/Collections/' $E/dump/root-peek/list.txt | grep -E '\.(HEIC|ca|caml)$' | awk '{print $4, $NF}' | sed 's#Library/Wallpaper/Collections/##' | cut -c1-120 | head -14
echo "== WallpaperKit paths in the dyld cache"
cd $E/dump/root-peek/dsc && for f in dyld_shared_cache_arm64*; do case "$f" in *.symbols|*.map) ;; *) LC_ALL=C grep -a -o -E '[ -~]{0,40}(Library/Wallpaper|/Wallpaper/Collections|WallpaperCollection\.plist)[ -~]{0,40}' "$f" 2>/dev/null ;; esac; done | sort | uniq -c | sort -rn | head -14 | cut -c1-130
