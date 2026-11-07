#!/bin/bash
# Wallpaper and widgets: what this boot's log says, and what is really on the root volume. Read-only.
L=$(ls -d /root/fuxi/log-gpu3/*/ | head -1)
echo "== poster/widget rows in msgbuf (gpu3)"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E '.{0,50}(PosterBoard|WallpaperKit|CollectionsPoster|WidgetRenderer|chronod|ExtensionKit|wallpaper).{0,120}' | sed -E 's/\[ *[0-9.]+\]//' | cut -c1-175 | sort | uniq -c | sort -rn | head -30
echo "== last slot clients / askers"
tail -n 400 "$L/slots.txt" | grep -a -E '^\[(gpu clients|metal askers)\]' | tail -2 | cut -c1-260
echo "== warnings that are not known noise"
grep -a -E '^(W|P[0-9]) ' "$L/slots.txt" | grep -a -v -E 'hostpages|binary archive|setGPUPriority' | cut -c1-120 | sort | uniq -c | sort -rn | head -14
echo "== root volume images"
ls -la /root/fuxi/ux-out/fuxi/userdata/ 2>/dev/null | cut -c1-110 | head
which apfs-fuse fsapfsinfo fsapfsmount 7z 7zz 2>/dev/null
ls /root/fuxi/apfs-fuse/build/apfs-fuse 2>/dev/null
echo "== local records of what is on the volume"
grep -l -a -r -E 'Health\.app|Fitness\.app|Bridge\.app|Weather\.app' /mnt/e/DSH-Fuxi/dump/wsl /mnt/e/DSH-Fuxi/*.md 2>/dev/null | head
echo "== previous flash records of boot_b"
grep -n -a -E 'flash boot_b|boot_b' /mnt/e/DSH-Fuxi/*.md 2>/dev/null | cut -c1-150 | head -12
echo "== upstream wallpaper commits"
U=/root/fuxi/src-unixnu
git -C $U log origin/main --format='%h %cI %s' -i --grep='wallpaper\|poster' | cut -c1-120 | head -14
A=/root/fuxi/src-adrenometal
git -C $A log origin/main --format='%h %cI %s' -i --grep='wallpaper\|poster\|widget\|WidgetRenderer' | cut -c1-120 | head -14
