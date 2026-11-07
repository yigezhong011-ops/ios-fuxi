#!/bin/bash
# Read-only: what the system catalogue holds, what Data holds, how the addon reaches Data, and which overlay the current kernel mounts.
E=/mnt/e/DSH-Fuxi
cd /root/fuxi/cat-test/wall/Library/Wallpaper || exit 1
ls -la . Collections | cut -c1-100
du -sh Collections/* | cut -c1-90
python3 -I - <<'PY'
import plistlib, glob, pprint
for f in ('DefaultWallpapers~ipad.plist', 'Collections/Collections~ipad.plist', 'Wallpapers~ipad.plist'):
    try:
        print('==', f); pprint.pprint(plistlib.load(open(f, 'rb')), width=110)
    except Exception as e:
        print('ERR', e)
for m in sorted(glob.glob('Collections/*.wallpaperCollection/WallpaperCollection.plist')):
    d = plistlib.load(open(m, 'rb'))
    print(m.split('/')[1], {k: (v if len(str(v)) < 90 else '...') for k, v in d.items()})
PY
ls Collections/Bokeh.wallpaperCollection/Wallpapers | head -12
find Collections/Bokeh.wallpaperCollection/Wallpapers -maxdepth 2 -name 'Wallpaper.plist' | head -1 | while read -r f; do python3 -I -c 'import plistlib,sys,pprint; pprint.pprint(plistlib.load(open(sys.argv[1],"rb")),width=110)' "$f"; done
A="python3 -I $E/dump/wsl/apfs-read.py $E/logs/data-raw.img"
echo '== Data ngpu'
$A ls 0 "ngpu" 2>&1 | tail -8 | cut -c1-100
$A ls 0 "ngpu/wallpaper" 2>&1 | tail -10 | cut -c1-100
$A ls 0 "ngpu/wallpaper/Collections" 2>&1 | tail -6 | cut -c1-100
echo '== addon code'
grep -n -E 'wallpaper|ngpu|already|exists|O_EXCL|O_TRUNC|sentinel|stamp|complete' $E/unixnu-build/fuxi/patches/xnu/zzy-native-gpu-addon-mount.patch | cut -c1-150 | head -60
echo '== strings'
K=/root/fuxi/t50-mine-gpu-storefix2/kernel.macho
strings -a "$K" | grep -E 'ngpu/wallpaper|/Library/Wallpaper' | cut -c1-200 | sort -u
ls -la /root/fuxi/t50-gpu-wall/ /root/fuxi/t50-mine-gpu-storefix2/ 2>&1 | cut -c1-90 | head -24
