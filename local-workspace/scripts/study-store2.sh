#!/bin/bash
# Read-only: the poster store's failure paths in the extracted dyld cache, using the earlier tools, and the phrases around them in the log.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
cd $S
ls -la $D | cut -c24-90 | head -8
tr -d '\r' < read-dsc-caller-lib.py | sed -n 40,140p | cut -c1-130
echo "=== read-dsc-build"; timeout 200 python3 -I read-dsc-build.py $D 2>&1 | cut -c1-170 | head -70
echo "=== log phrases"
for p in 'could not setup data store' 'could not validate data store' 'failed to setup database' 'evades explanation' 'language change' 'Unable to determine' 'preferred language' 'AppleLanguages' 'Stashed' 'stashed locale' 'com.apple.migration'; do printf '%-34s %s\n' "$p" "$(grep -a -c -- "$p" $L)"; done
