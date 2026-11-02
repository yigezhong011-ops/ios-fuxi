#!/bin/bash
# Where the iPadOS 17.7.11 system files are on this machine (IPSW, mounted/extracted root, APFS images), for the 7570 wallpaper
ls -la /mnt/e/DSH-Fuxi/*.ipsw /mnt/e/*.ipsw /root/fuxi/*.ipsw 2>/dev/null
find /mnt/e/DSH-Fuxi /root/fuxi -maxdepth 4 \( -iname '*.ipsw' -o -iname '*.aea' -o -iname '*.dmg' -o -iname 'iPad_*' \) 2>/dev/null | head -20
find /mnt/e/DSH-Fuxi /root/fuxi -maxdepth 8 -path '*7570.iPadOS_17*' 2>/dev/null | head -5
which heif-convert heif-dec apfs-fuse ipsw 7z 2>/dev/null
python3 -c 'import pillow_heif' 2>&1 | tail -1
echo "== clients"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/list-gpu-addon.py /root/fuxi/t32/kernel.macho.gpuaddon --extract /root/fuxi/t32-addon >/dev/null && cat /root/fuxi/t32-addon/addons/NativeAdrenoMetal.clients
echo "== payload FAT"
mdir -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/Payloads 2>/dev/null
minfo -i /root/fuxi/t32/vol.img 2>/dev/null | grep -i -E 'sector size|cluster|total|free' | head
