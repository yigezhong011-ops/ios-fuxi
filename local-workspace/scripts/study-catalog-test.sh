#!/bin/bash
# Inputs for the phone wallpaper catalog test: catalog contents, the mount function, and the overlay in the running image. Read-only apart from /root/fuxi/cat-test.
E=/mnt/e/DSH-Fuxi; P=$E/dump/root-peek; B=$E/unixnu-build/fuxi; W=/root/fuxi/cat-test
mkdir -p $W; cd $W || exit 1
L=$P/list.txt
echo "== which volume holds the wallpapers"
ls -la $E/*.ipsw $E/ipsw 2>/dev/null | cut -c1-110 | head
grep -n -E 'Library/Wallpaper/Collections/Collections' $L | cut -c1-110
sed -n '1,3p' $P/sys-list.txt | cut -c1-100
grep -a -c 'Library/Wallpaper' $P/sys-list.txt
echo "== mount function"
P2=$B/patches/xnu/zzy-native-gpu-addon-mount.patch
grep -n 'native_gpu_addon_mount' $P2 | head -3
awk '/^\+native_gpu_addon_mount\(/{p=1} p{print} /^\+}/{if(p){exit}}' $P2 | cut -c1-175
echo "== mount flags defined"
grep -n -E 'MNT_UNION|MNT_DONTBROWSE|0x800|0x600|0x400|BINDFS|bindfs|"bindfs"|union' $P2 | cut -c1-170 | head -24
echo "== bind/union in vnops"
sed -n '/bind_vfsops.c/,+40p' $P2 | cut -c1-140 | head -60
echo "== files in the addon of the running image"
ls -la $E/dump/wsl/addons 2>/dev/null | cut -c1-90 | head
ls -d /root/fuxi/t50-* 2>/dev/null | head -20
sed -n '1,60p' $E/dump/wsl/fit-addon.py | cut -c1-170
