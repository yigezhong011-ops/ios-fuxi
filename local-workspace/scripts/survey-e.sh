#!/bin/bash
# Read-only size survey of E:. Moves and deletes nothing.
cd /mnt/e
df -h /mnt/e | tail -1
echo '--- E: top level'
du -xsh -- * 2>/dev/null | sort -rh | head -25
echo '--- DSH-Fuxi top level, largest'
cd DSH-Fuxi
du -xsh -- * 2>/dev/null | sort -rh | head -40
echo '--- DSH-Fuxi images, largest 40 with date'
find . -maxdepth 1 -type f \( -name '*.img' -o -name '*.ipsw' -o -name '*.zip' -o -name '*.bin' \) -printf '%s %TY-%Tm-%Td %f\n' | sort -rn | head -40 | awk '{printf "%7.0fM %s %s\n",$1/1048576,$2,$3}'
echo "image count: $(find . -maxdepth 1 -type f -name '*.img' | wc -l)"
echo '--- 待删除'
du -sh 待删除 2>/dev/null; ls 待删除 2>/dev/null | head -30
echo '--- WSL root'
du -xsh /root/fuxi /root/hakios-xnu-kernel /root/build 2>/dev/null
