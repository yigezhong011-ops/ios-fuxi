#!/bin/bash
D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
mkdir -p $D; cd $D || exit 1
[ -n "$(ls 2>/dev/null | head -1)" ] || 7z e -y -bd /mnt/e/DSH-Fuxi/dump/root-peek/systemos.img 'System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64*' -x'!*.symbols' >/dev/null 2>&1
ls | wc -l; du -sh .; df -h /mnt/e | tail -1
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-dsc-assert.py $D 2>&1 | cut -c1-170 | tail -240
