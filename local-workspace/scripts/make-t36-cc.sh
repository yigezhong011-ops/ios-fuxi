#!/bin/bash
# t36-cc: the daily t36-bl2 with the phone display properties pong sets and t36 lacks (Control Center drawn as a small centred
# panel): /chosen display-scale 3 (FrontBoard's software coordinate scale), and in /product artwork-dynamic-displaymode "0",
# compatible-app-variant "0", compatible-device-fallback iPhone15,2. The ADT grows within its own last cluster (fat-inplace --grow).
set -euo pipefail
OUT=${1:-t36-cc}
W=/root/fuxi/$OUT; rm -rf $W; mkdir -p $W
export MTOOLS_SKIP_CHECK=1
cp /root/fuxi/t36-bl2/vol.img $W/vol.img
mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt $W/old.adt
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-edit.py $W/old.adt $W/new.adt \
  '/device-tree/chosen:display-scale=u32:3' \
  '/device-tree/product:artwork-dynamic-displaymode=str:0' \
  '/device-tree/product:compatible-app-variant=str:0' \
  '/device-tree/product:compatible-device-fallback=str:iPhone15,2'
for n in /device-tree/chosen /device-tree/product; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py $n $W/new.adt | grep -E 'display-scale|artwork|compatible|product-name'
done
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt $W/new.adt --grow
mcopy -n -i $W/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt $W/check.adt && cmp $W/new.adt $W/check.adt && echo "ADT read back OK"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-bl2.img $W/vol.img /mnt/e/DSH-Fuxi/$OUT.img
