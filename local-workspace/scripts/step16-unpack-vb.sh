#!/bin/bash
set -uo pipefail
cd /root/fuxi
cp /mnt/e/DSH-Fuxi/backup/vendor_boot_a.img .
rm -rf vb_out && mkdir -p vb_out
python3 /mnt/e/DSH-Fuxi/dump/tools/unpack_bootimg.py --boot_img vendor_boot_a.img --out vb_out 2>&1 | tail -12
echo "=== 产物 ==="
ls -l vb_out | head -12
echo "=== 找 fstab ==="
cd vb_out
for f in *ramdisk*; do
  [ -f "$f" ] || continue
  echo "--- $f ---"
  file "$f" 2>/dev/null
  mkdir -p /root/fuxi/rd && rm -rf /root/fuxi/rd/* 
  case "$f" in
    *.gz) gunzip -c "$f" > /root/fuxi/rd.cpio ;;
    *) cp "$f" /root/fuxi/rd.cpio ;;
  esac
  cd /root/fuxi/rd && cpio -idm --quiet < /root/fuxi/rd.cpio 2>/dev/null || true
  cd /root/fuxi/vb_out
  find /root/fuxi/rd -name 'fstab*' 2>/dev/null | head -5
done
echo VB_DONE
