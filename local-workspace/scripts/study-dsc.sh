#!/bin/bash
# Pull the dyld shared cache headers out of SystemOS and find the PosterBoard framework. Read-only on the image.
W=/mnt/e/DSH-Fuxi/dump/root-peek
grep -a -E 'com\.apple\.dyld/' $W/sys-list.txt | cut -c1-110 | head -40
df -h /mnt/e | tail -1
grep -a -i -E 'PosterBoard' $W/list.txt | grep -a -v -E 'Assets|lproj|\.car' | cut -c1-120 | head -8
which llvm-objdump llvm-objdump-18 2>/dev/null; ls /usr/bin | grep -i objdump | head
