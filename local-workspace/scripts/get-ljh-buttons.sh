#!/bin/bash
# Fetch the t32 author's button/HID sources (read-only) into E:\DSH-Fuxi\read\ljh-old
set -e
out=/mnt/e/DSH-Fuxi/read/ljh-old
mkdir -p "$out"
for f in package/FuxiButtons.cpp package/HidInputProbe.cpp scripts/build-native-hid-input.py \
         board.toml package/LegacyDisplayProbe.cpp scripts/build-native-legacy-display.py package/BootLog.c; do
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py ljhhkx529/unixnu-fuxi 622b444a1f "$f" "$out/$(basename "$f")"
done
