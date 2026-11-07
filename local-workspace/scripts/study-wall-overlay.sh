#!/bin/bash
# Read-only: the wallpaper overlay upstream describes, whether our images carry it, and what the last boot's log says about it.
U=/root/fuxi/up-latest
cd $U
echo "== overlay scripts"; git ls-files | grep -i -E 'wallpaper|poster' | head -20
for f in scripts/make-wallpaper-overlay.py; do [ -f $f ] && { wc -l $f; sed -n 1,60p $f | cut -c1-140; }; done
echo "== in our tree"
for d in /root/fuxi/unixnu-fuxi /root/fuxi/uni-old /root/fuxi/UniXNU; do [ -d $d ] && { echo $d; grep -rIl -E 'WALLPAPER|wallpaper' $d --include='*.py' --include='*.c' --include='*.sh' --include='*.patch' --include='*.toml' 2>/dev/null | head -12; }; done
echo "== our scripts"
grep -l -i wallpaper /mnt/e/DSH-Fuxi/dump/wsl/* 2>/dev/null | head -20
echo "== logs"
ls -dt /root/fuxi/wall*/ 2>/dev/null | head -5
L=$(ls -t /root/fuxi/wall*/log* 2>/dev/null | head -1); echo "log=$L"
ls -la /root/fuxi/wall1 2>/dev/null | head -12
