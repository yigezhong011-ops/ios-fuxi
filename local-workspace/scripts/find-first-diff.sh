#!/bin/bash
# First differing 4 MiB block between the phone's userdata and the local image (scans blocks 0..N).
ADB=/mnt/e/DSH-Fuxi/tools/platform-tools/adb.exe
IMG=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
N=${1:-128}
$ADB shell "i=0; while [ \$i -lt $N ]; do dd if=/dev/block/by-name/userdata bs=4194304 skip=\$i count=1 2>/dev/null | sha256sum | cut -c1-16; i=\$((i+1)); done" | tr -d '\r' > /root/fuxi/rh.txt
for i in $(seq 0 $((N-1))); do dd if="$IMG" bs=4M skip=$i count=1 status=none | sha256sum | cut -c1-16; done > /root/fuxi/lh.txt
paste /root/fuxi/lh.txt /root/fuxi/rh.txt | awk '$1!=$2 {print "first diff block", NR-1, "(", (NR-1)*4, "MiB )"; exit}'
echo "differing blocks: $(paste /root/fuxi/lh.txt /root/fuxi/rh.txt | awk '$1!=$2' | wc -l) of $N"
