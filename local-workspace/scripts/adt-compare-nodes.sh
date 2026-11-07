#!/bin/bash
# Compare key ADT nodes: adtmatch (our kernel reached bsd_init) vs the CI ADT (touch kernel hangs early).
set -euo pipefail
cd /root/fuxi/adtcmp2
cp /root/fuxi/pkg-unixnu-fts7a/root/EFI/UniXNU/Payloads/kernel.macho.adt ci.adt
for n in /device-tree /device-tree/cpus /device-tree/cpus/cpu0 /device-tree/cpus/cpu7 /device-tree/arm-io /device-tree/arm-io/intc; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py "$n" adtmatch.adt ci.adt | grep -v -E 'random-seed|nvram-proxy'
done
