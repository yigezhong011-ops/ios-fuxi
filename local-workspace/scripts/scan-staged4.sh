#!/sbin/sh
# Runs in TWRP. Read-only. What surrounds the Weather.app hits, and do copied directory names appear at all?
D=/dev/block/by-name/userdata
dd if=$D bs=1048576 skip=$((212039 + 320)) count=65 2>/dev/null | tail -c +$((14815710 - 2048)) | head -c 45000 > /tmp/weather.bin
for s in Music.app _CodeSignature; do
  echo "== $s"
  i=0
  while [ $i -lt 16384 ]; do
    dd if=$D bs=1048576 skip=$((212039 + i)) count=65 2>/dev/null | grep -a -b -o -F -e "$s" | sed "s/^/$i:/" | head -12
    i=$((i + 64))
  done
done
echo done
