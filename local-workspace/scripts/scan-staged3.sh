#!/sbin/sh
# Runs in TWRP. Read-only. One string per grep, in case several -e lost hits, plus the bytes around the four earlier hits.
D=/dev/block/by-name/userdata
n=0
for hit in 1728:26005777 1728:26018326 2176:10218454 2176:10224881; do
  c=${hit%%:*}; o=${hit##*:}
  dd if=$D bs=1048576 skip=$((212039 + c)) count=65 2>/dev/null | tail -c +$((o - 1024)) | head -c 4096 > /tmp/ctx-$n.bin
  n=$((n + 1))
done
for s in Freeform.app Weather.app .sheng-staged-apps; do
  echo "== $s"
  i=0
  while [ $i -lt 16384 ]; do
    dd if=$D bs=1048576 skip=$((212039 + i)) count=65 2>/dev/null | grep -a -b -o -F -e "$s" | sed "s/^/$i:/"
    i=$((i + 64))
  done
done
echo done
