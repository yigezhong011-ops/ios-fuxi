#!/bin/bash
# Where can the root volume or the PosterBoard executable be had locally? Read-only.
find /root/fuxi /mnt/e/DSH-Fuxi -maxdepth 5 -type f \( -iname 'userdata-root*' -o -iname '*.ipsw' -o -iname '*.dmg' -o -iname 'PosterBoard' -o -iname 'dyld_shared_cache_arm64*' -o -iname 'build-userdata*' -o -iname 'push-userdata*' \) -size +0 2>/dev/null | head -20 | while read -r f; do ls -la "$f" | cut -c24-140; done
for s in /mnt/e/DSH-Fuxi/dump/wsl/build-userdata.sh /root/fuxi/build-userdata.sh; do
  [ -f "$s" ] && { echo "== $s"; grep -n -E 'seek|skip|lba|LBA|offset|root\.img|OS\.dmg|\.dmg|ipsw|http|mkfs|apfs|hfs|hdiutil|7z' "$s" | cut -c1-170 | head -24; }
done
which 7z 7zz; 7z i 2>/dev/null | grep -i -E 'apfs|hfs' | head
df -h /mnt/e | tail -1
grep -n -E 'ipsw|\.dmg|OS\b.*dmg|root volume|根卷' /mnt/e/DSH-Fuxi/UNIXNU-PROGRESS.md | cut -c1-170 | head -10
