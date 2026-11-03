#!/bin/bash
# Is the ROM package's recovery.img a TWRP/OrangeFox (adb root shell) or Xiaomi's stock recovery? Read-only.
R="/mnt/e/iOS小米13/17系261005_Mi13_OS4.0.0.32_4e0b/firmware-update/recovery.img"
W=/root/fuxi/rec-check; rm -rf $W; mkdir -p $W
head -c 8 "$R"; echo
python3 -I - "$R" $W <<'EOF'
import struct, sys
d = open(sys.argv[1], 'rb').read()
ver = struct.unpack_from('<I', d, 40)[0]
ks, rs = struct.unpack_from('<II', d, 8)
print('header version', ver, 'kernel', ks, 'ramdisk', rs)
page = 4096
koff = page; roff = koff + (ks + page - 1) // page * page
open(sys.argv[2] + '/ramdisk', 'wb').write(d[roff:roff + rs])
open(sys.argv[2] + '/kernel', 'wb').write(d[koff:koff + ks])
EOF
cd $W
file ramdisk
(lz4 -dc ramdisk 2>/dev/null || gzip -dc ramdisk 2>/dev/null || xz -dc ramdisk 2>/dev/null) > ramdisk.cpio
ls -l ramdisk ramdisk.cpio
for s in TeamWin TWRP twrp OrangeFox skkk "ro.twrp" adbd miui_recovery MiRecovery; do
  printf '%-14s %s\n' "$s" "$(grep -c -a -- "$s" ramdisk.cpio)"
done
strings -n 8 ramdisk.cpio | grep -iE 'twrp.*version|ro\.twrp|fox_version|skkk' | sort -u | head
