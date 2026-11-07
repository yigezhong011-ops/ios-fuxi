#!/bin/bash
# Find and fetch the backlight probe sources the t32 kernel was built from (read-only)
out=/mnt/e/DSH-Fuxi/read/backlight
mkdir -p "$out"
for repo in ljhhkx529/unixnu-fuxi:old UniXNU/UniXNU-sheng:main; do
    r=${repo%%:*}; b=${repo##*:}
    echo "== $r@$b"
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-grep-tree.py "$r" "$b" 'backlight|panel|dsi' | grep -v -E 'firmware/|\.dts' | head -30
done
for f in package/BacklightProbe.cpp package/AppleARMBacklight.cpp; do
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py ljhhkx529/unixnu-fuxi old "$f" "$out/ljh-$(basename "$f")" || true
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py UniXNU/UniXNU-sheng main "$f" "$out/sheng-$(basename "$f")" || true
done
ls -la "$out"
