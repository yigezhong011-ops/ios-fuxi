#!/bin/bash
# Does t32's NativeAdrenoMetal plugin know the cache export / pipeline pack / client text features from the GPU doc?
set -e
D=/root/fuxi/t32/addon-x; rm -rf $D; mkdir -p $D
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/list-gpu-addon.py /root/fuxi/t32/kernel.macho.gpuaddon --extract $D >/dev/null
P=$D/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal
for s in NativeAdrenoMetal.cacheexport NativeAdrenoMetal.m2vpack NativeAdrenoMetal.primelist SHEXP001 prime-done 'gpu client'; do
  printf '%-32s %s\n' "$s" "$(grep -c -a -- "$s" $P)"
done
