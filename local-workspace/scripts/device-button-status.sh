#!/bin/bash
# How other UniXNU devices describe their button support (read-only)
for d in sheng asteroids alioth komodo; do
    echo "== $d"
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py UniXNU/UniXNU main "docs/.vitepress/device-records/$d.toml" \
        | grep -i -n -B2 -A4 -E 'button|volume|power key|lock' | head -40
done
