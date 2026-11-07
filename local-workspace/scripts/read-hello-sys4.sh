#!/bin/bash
# Same search on userdata-root.img, read-only. Output stays in a work directory inside WSL.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; O=/root/fuxi/hello-look; mkdir -p $O; cd $O
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py "$I" info 2>&1 | cut -c1-160 | head -12
7z l -ba "$I" > list2.txt 2>&1; wc -l list2.txt; head -4 list2.txt | cut -c1-120
grep -a -E 'HelloPoster' list2.txt | cut -c54- | head -24
grep -a -c 'metallib' list2.txt
