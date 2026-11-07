#!/bin/bash
# List HelloPoster in the local system image and pull its files for reading. Local reads only.
I=/root/fuxi/sys-peek/systemos.img; A=/mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py; O=/root/fuxi/hello-look; mkdir -p $O; cd $O
sed -n 1,8p $A | cut -c1-110
python3 -I $A $I ls /System/Library/PrivateFrameworks/HelloPoster.framework 2>&1 | cut -c1-100 | head -25
python3 -I $A $I ls /System/Library/PrivateFrameworks/HelloPoster.framework/PlugIns/HelloPosterExtension.appex 2>&1 | cut -c1-100 | head -25
echo '--- raw hits'
grep -a -b -o -E 'pro24MainFragment|lightsMeshFragment' $I 2>/dev/null | head -6
