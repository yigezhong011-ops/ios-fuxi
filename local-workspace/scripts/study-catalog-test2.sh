#!/bin/bash
# Where is the OS image, what do the catalogs say, and what does the t50 kernel and addon carry? Read-only apart from /root/fuxi/cat-test.
E=/mnt/e/DSH-Fuxi; P=$E/dump/root-peek; W=/root/fuxi/cat-test; L=$P/list.txt
export MTOOLS_SKIP_CHECK=1
echo "== os images"
find $E /root/fuxi -maxdepth 4 \( -iname '*.ipsw' -o -iname '*.dmg' -o -iname '*.aea' -o -iname '*rootfs*' \) -size +100M 2>/dev/null | head -12
ls -la $E/待删除 2>/dev/null | cut -c1-100 | head -24
grep -l 'root-peek' $E/dump/wsl/*.sh 2>/dev/null | head -5
grep -h -E '7z (l|x|e) ' $E/dump/wsl/study-*.sh 2>/dev/null | grep -v systemos | cut -c1-170 | head -6
echo "== wallpaper tree"
grep -a -E 'Library/Wallpaper/Collections/[^/]+(/[^/]+)?$' $L | awk '{print $NF}' | cut -c27- | head -30
echo "-- files of one Bokeh wallpaper"
grep -a -E '5010\.Multicolored\.wallpaper/' $L | awk '{print $4, $NF}' | sed 's#Library/Wallpaper/Collections/##' | cut -c1-120 | head -24
echo "-- files of one Stripe wallpaper"
grep -a -E '7365\.Stripe_Green\.wallpaper/' $L | awk '{print $4, $NF}' | sed 's#Library/Wallpaper/Collections/##' | cut -c1-120 | head -16
echo "== file extensions under Collections"
grep -a 'Library/Wallpaper/Collections/' $L | awk '{print $NF}' | grep -o -E '\.[A-Za-z0-9]+$' | sort | uniq -c | sort -rn | head
echo "== t50 volume"
V=/root/fuxi/t50-gpu-apps/vol.img
mdir -i $V ::/EFI/UniXNU/Payloads 2>/dev/null | cut -c1-70 | head -16
mcopy -n -i $V ::/EFI/UniXNU/Payloads/kernel.macho $W/kernel.macho 2>/dev/null
ls -la $W/kernel.macho | cut -c1-80
for s in '/private/var/ngpu/wallpaper' 'iPadOS_17~ipad.wallpaperCollection/Wallpapers' '/private/var/ngpu/daemons'; do echo "'$s': $(LC_ALL=C grep -a -c -F "$s" $W/kernel.macho) lines"; done
LC_ALL=C grep -a -o -b -E '/Library/Wallpaper[ -~]*' $W/kernel.macho | cut -c1-220 | head
LC_ALL=C grep -a -o -b -E '/private/var/ngpu/[ -~]*' $W/kernel.macho | cut -c1-120 | head
echo "== addon"
mdir -i $V ::/EFI/UniXNU 2>/dev/null | cut -c1-70 | head -12
mtype -i $V ::/EFI/UniXNU/unixnu.toml | tr ' ' '\n' | grep -E 'addon|sheng-gpu|sheng-staged|sheng-setup' | head
sha256sum $E/t50-mine-gpu-fix.img | cut -c1-16
