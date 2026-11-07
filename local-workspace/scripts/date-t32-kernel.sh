#!/bin/bash
# Date t32's Adreno740 kernel driver by boot-arg / feature strings introduced upstream on known dates.
K=/root/fuxi/t32/kernel.macho
P=/root/fuxi/t32/addon-x/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal
for s in sheng-gpu-timeline sheng-gpu-prime sheng-gpu-owned-coherent sheng-gpu-log log-gpu sheng-gpu-frame sheng-gpu-ring2 preempt hangcheck sheng-gpu-pixel; do
  printf '%-26s kernel=%s plugin=%s\n' "$s" "$(grep -c -a -- "$s" $K)" "$(grep -c -a -- "$s" $P)"
done
