#!/bin/bash
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq lz4 cpio 2>&1 | tail -1
cd /root/fuxi/vb_out
ls -l vendor-ramdisk-by-name | head
rm -rf /root/fuxi/rd && mkdir -p /root/fuxi/rd
lz4 -d -c vendor_ramdisk00 > /root/fuxi/rd.cpio 2>/dev/null || unlz4 -c vendor_ramdisk00 > /root/fuxi/rd.cpio
file /root/fuxi/rd.cpio
cd /root/fuxi/rd
cpio -idm --quiet < /root/fuxi/rd.cpio 2>&1 | tail -3
echo "=== fstab 文件 ==="
find /root/fuxi/rd -iname 'fstab*' | head -10
for f in $(find /root/fuxi/rd -iname 'fstab*' | head -5); do
  echo "--- $f ---"
  grep -nE 'userdata|metadata|encrypt' "$f" | head -10
done
echo STEP17_DONE
