#!/bin/bash
# Wallpaper / GPU addon references (read-only) into E:\DSH-Fuxi\read\wallpaper
out=/mnt/e/DSH-Fuxi/read/wallpaper
mkdir -p "$out"
get() { python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py "$1" "$2" "$3" "$out/$4" 2>&1 | tail -1; }
get UniXNU/UniXNU main scripts/make-wallpaper-overlay.py make-wallpaper-overlay.py
get UniXNU/UniXNU main scripts/make-gpu-addon.py make-gpu-addon.py
get UniXNU/UniXNU main docs/zh/porting/packaging.md packaging-zh.md
get UniXNU/UniXNU main docs/zh/porting/gpu.md gpu-zh.md
get UniXNU/UniXNU main docs/zh/devices/asteroids.md asteroids-zh.md
get lonzzi/UniXNU-houji main archive/docs/houji-dvfs-and-wallpaper.md houji-dvfs-and-wallpaper.md
get hanyaa380/UniXNU-dipper main scripts/make-fajita-wallpaper-addon.py dipper-make-fajita-wallpaper-addon.py
get ljhhkx529/unixnu-fuxi old build-boot-image.sh ljh-build-boot-image.sh
ls -la "$out"
echo "== t32 gpu addon"
ls -la /root/fuxi/t32/kernel.macho.gpuaddon
file /root/fuxi/t32/kernel.macho.gpuaddon
xxd /root/fuxi/t32/kernel.macho.gpuaddon | head -4
