#!/bin/bash
set -uo pipefail
echo "=== 删除 WSL 内不再需要的大文件 ==="
rm -rf /root/fuxi/root-clean.img /root/fuxi/build-1616 /root/fuxi/rd /root/fuxi/rd.cpio \
       /root/fuxi/ramdisk_new.cpio /root/fuxi/vb_out /root/fuxi/vb_check \
       /root/fuxi/vendor_ramdisk_new.lz4 /root/fuxi/root-*.img 2>/dev/null
rm -rf /root/uefi-fuxi /root/UniXNU /root/hackios /root/apfs-fuse /root/local-feed 2>/dev/null
rm -f /root/fuxi/payload-from-image.bin 2>/dev/null
df -h / | tail -1
echo "=== 剩余 ==="
du -sh /root/* 2>/dev/null | sort -rh | head -6
