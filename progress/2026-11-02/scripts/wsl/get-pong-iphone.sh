#!/bin/bash
# pong's iPhone-presentation pieces (read-only) into E:\DSH-Fuxi\read\pong-iphone
out=/mnt/e/DSH-Fuxi/read/pong-iphone
mkdir -p "$out"
for f in userland/ui_compat18.c userland/init.c userland/settings_compat18.c userland/build-ipados18.py \
         os-profiles/ipados-18.7.10-22H374/profile.toml migration/ipados18/services.md migration/ipados18/README.zh.md; do
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py Chengdong-Yu/UniXNU-pong main "$f" "$out/$(basename "$f")" 2>&1 | tail -1
done
echo "== services.md lines on identity / island"
grep -n -i -E 'iPhone17|dynamic island|灵动岛|2622|idiom|MobileGestalt|phone 布局|iPhone 布局|SystemAperture' "$out/services.md" | head -40
