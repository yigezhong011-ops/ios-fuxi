#!/sbin/sh
# Runs in TWRP. Read-only: where is the PosterBoard executable on the root volume, and is its data store on Data?
D=/dev/block/by-name/userdata
echo "== control on Data"
i=0
while [ $i -lt 16384 ]; do
  dd if=$D bs=1048576 skip=$((212039 + i)) count=65 2>/dev/null | grep -a -c -F -e com.apple.PosterBoard | sed "s/^/data $i: /" | grep -v ': 0$'
  i=$((i + 64))
done
echo "== root"
i=0
while [ $i -lt 61440 ]; do
  dd if=$D bs=1048576 skip=$i count=65 2>/dev/null | grep -a -b -o -F -e PBFModalRootViewController -e 7712ed3b | sed "s/^/$i:/" | head -40
  i=$((i + 64))
done
echo done
