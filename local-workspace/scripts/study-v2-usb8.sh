#!/bin/bash
# Read-only: does each branch carry the AMP patch, cluster types and the cpufreq probe.
cd /root/fuxi/ref-fuxi-v2 || exit 1
for b in origin/old origin/V2; do
  echo "== $b"
  echo "amp patch: $(git ls-tree -r --name-only $b | grep -c 'zzyf-sheng-amp')"
  echo "series: $(git show $b:patches/xnu/series 2>/dev/null | grep -c 'zzyf-sheng-amp')"
  echo "cluster-type in tree: $(git grep -l 'cluster-type' $b -- '*.dts' '*.dtsi' | wc -l)"
  echo "CpuFreqProbe: $(git ls-tree -r --name-only $b | grep -c CpuFreqProbe)"
  echo "GPU addon scripts: $(git ls-tree -r --name-only $b | grep -ciE 'gpu-addon|adreno')"
done
