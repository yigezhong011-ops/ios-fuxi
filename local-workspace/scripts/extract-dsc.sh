#!/bin/bash
# Extract the dyld shared cache from the local root volume image into WSL. The image is only read. Nothing goes to C: or into any repository.
set -uo pipefail
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
W=/root/fuxi/sys-peek; mkdir -p "$W/dsc"
[ -s "$W/systemos.img" ] || dd if="$I" of="$W/systemos.img" bs=1048576 iflag=skip_bytes skip=6079643648 count=3150 status=none
ls -la "$W/systemos.img" | cut -c24-100
cd "$W/dsc"
[ -n "$(ls 2>/dev/null | head -1)" ] || 7z e -y -bd "$W/systemos.img" 'System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64*' -x'!*.symbols' >/dev/null 2>&1
ls -la | cut -c24-90 | head -20
du -sh "$W"
