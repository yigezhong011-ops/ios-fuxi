#!/bin/bash
# Does the t50 kernel still mount the wallpaper overlay, where, and who may open the GPU client? Did a Poster process run? Read-only.
K=/root/fuxi/t50-mine/kernel.macho
echo "== wallpaper strings in the t50 kernel"; strings -a $K | grep -E 'ngpu/wallpaper|wallpaperCollection|\.wallpaper/|wallpaper-floating' | cut -c1-210 | sort -u
echo "== grant list candidates"; strings -a $K | grep -E 'iconservicesagent|WidgetRenderer|PosterBoard|CollectionsPoster' | cut -c1-200 | sort -u | head
D=$(ls -d /root/fuxi/log-gpufix/*/ | head -1)
echo "== poster mentions in the gpu-fix log"
tr -d '\0' < "$D/msgbuf.txt" | grep -a -o -E '.{70}(PosterBoard|CollectionsPoster|PhotosPoster|ExtragalacticPoster|WallpaperKit)[^ ]*.{50}' | cut -c1-190 | head -14
grep -a -c 'PosterBoard\|CollectionsPoster' "$D/slots.txt"
echo "== launchd job names over the whole log"
L=$(ls -t /mnt/e/DSH-Fuxi/logs/gpu-fix-*.log | head -1)
grep -a -i -E 'poster|wallpaper' "$L" | cut -c1-190 | head -12
echo "== wallpapers in the OS volume"
ls /mnt/e/DSH-Fuxi/ux-out/fuxi/ 2>/dev/null | head
find /root/fuxi /mnt/e/DSH-Fuxi/ux-out -maxdepth 5 -type d -name 'iPadOS_17~ipad.wallpaperCollection' 2>/dev/null | head -3
echo "== CI"; bash /root/fuxi/crst.sh 41773883659 | sed -n 1p
