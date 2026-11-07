#!/sbin/sh
# Runs in TWRP. Read-only: byte offsets of fixed strings in the Data area. Rows: <chunk MiB>:<offset>:<string>
D=/dev/block/by-name/userdata
BASE=212039
i=0
while [ $i -lt 16384 ]; do
  dd if=$D bs=1048576 skip=$((BASE + i)) count=65 2>/dev/null | grep -a -b -o -F -e PBFModalRootViewController -e PBFPosterExtensionDataStore -e behaviorAssertionProvider -e '"asi" :' -e PRBPosterExtensionDataStore | sed "s/^/$i:/"
  i=$((i + 64))
done
echo done
