#!/bin/bash
# Read-only: the sealed iPadOS 17 wallpaper's files, any iPhone iOS 17 wallpaper locally, and the room in the boot volume.
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; I=$E/ux-out/fuxi/userdata/userdata-root.img; W=/root/fuxi/w7570; C='Library/Wallpaper/Collections/iPadOS_17~ipad.wallpaperCollection'
mkdir -p $W
7z l "$I" "$C/*" 2>/dev/null | awk 'NF>=4' | grep -E 'wallpaper|Wallpaper|\.ca|plist|HEIC|png|caml' | awk '{s=$(NF-2)} {print}' | cut -c20-220 | head -60
7z l "$I" "$C/*" 2>/dev/null | tail -2 | cut -c1-90
rm -rf $W/root; 7z x -y -bd -o$W/root "$I" "$C/*" >/dev/null 2>&1
cd $W/root/$C || exit 1
python3 -I - <<'PY'
import plistlib, glob
for m in sorted(glob.glob('Wallpapers/*/Wallpaper.plist')):
    d = plistlib.load(open(m, 'rb'))
    print(m.split('/')[1]); print({k: v for k, v in d.items() if k != 'assets'})
    print(d.get('assets'))
PY
find . -type f | sed 's/.*\.//' | sort | uniq -c
du -sh . ; find . -name '*.HEIC' -printf '%s %p\n' | sort -rn | head -12 | cut -c1-170
echo '== any phone iOS 17 wallpaper here'
find /root/fuxi /mnt/e/DSH-Fuxi/read /mnt/e/DSH-Fuxi/wallpaper-overlay /mnt/e/DSH-Fuxi/ux-out -maxdepth 6 \( -iname '*~iphone*wallpaper*' -o -iname '*iOS_17*' -o -iname '*iphone*.wallpaper' \) 2>/dev/null | grep -v w7570 | head
ls -la $E/wallpaper-overlay | head -12 | cut -c20-; ls /mnt/e/DSH-Fuxi/*.ipsw /mnt/e/DSH-Fuxi/ipsw /mnt/e/*.ipsw 2>/dev/null | head
echo '== boot volume'
V=/root/fuxi/t50-wallred/vol.img
minfo -i $V :: 2>/dev/null | grep -E 'sector size|cluster size|big size|sectors per cluster' | head
mdir -i $V ::/EFI/UniXNU/Payloads 2>/dev/null | tail -14
mtype -i $V ::/EFI/UniXNU/unixnu.toml | grep -v args | cut -c1-120 | head -24
grep -n -E 'NATIVE_GPU_ADDON_MAX|addon_max|too large|EFBIG|bytes *>|MiB|gpuaddon|gpu_addon' $E/unixnu-build/fuxi/patches/xnu/zzy-native-gpu-addon-mount.patch | cut -c1-150 | head -14
grep -rn -l 'gpuaddon' $E/unixnu-build/uefi-fuxi 2>/dev/null | head -5
