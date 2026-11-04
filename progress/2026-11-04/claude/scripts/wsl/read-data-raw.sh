#!/bin/bash
# Trim dd's status text from the pulled Data copy, verify it against the phone's hash, list it. Local only: the copy and its listing must never be uploaded.
R=/mnt/e/DSH-Fuxi/logs/data-raw.img; O=/mnt/e/DSH-Fuxi/logs/data-list.txt; WANT=7f2568d2648c2a1944f0890c071f9f52154181ce15140b4abbcd31d973e633db
SIZE=17179869184
[ "$(stat -c%s "$R")" -ge "$SIZE" ] || { echo "short copy"; exit 1; }
[ "$(stat -c%s "$R")" = "$SIZE" ] || truncate -s "$SIZE" "$R"
H=$(sha256sum "$R" | cut -d' ' -f1); [ "$H" = "$WANT" ] && echo "hash OK" || echo "hash MISMATCH $H"
7z l -ba "$R" > "$O" 2>/mnt/e/DSH-Fuxi/logs/data-list.err
wc -l "$O"; head -4 /mnt/e/DSH-Fuxi/logs/data-list.err | cut -c1-140
echo "== poster store"; grep -a -E 'PRBPosterExtensionDataStore' "$O" | grep -v -E 'GalleryCache/.+/' | awk '{print $1,$2,$3,$4,$NF}' | cut -c1-170 | head -30
echo "== overlay"; grep -a -E 'ngpu/wallpaper' "$O" | awk '{print $4,$NF}' | cut -c1-120 | head -8
echo "== migration plist"; grep -a -E 'Preferences/com\.apple\.migration\.plist' "$O" | cut -c1-120
