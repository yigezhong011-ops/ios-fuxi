#!/bin/bash
# Read-only: the cpufreq probe source, how it differs from the other fuxi trees, and every recorded clocks row.
cd /root/fuxi || exit 1
A=fuxi2/package/CpuFreqProbe.cpp
for B in fuxi2/kits/sheng/CpuFreqProbe.cpp ref-sad-fuxi/package/CpuFreqProbe.cpp ux-device/package/CpuFreqProbe.cpp fork-device/package/CpuFreqProbe.cpp; do
  echo "=== diff $B: $(diff "$A" "$B" | grep -c '^[<>]') lines"
done
echo "=== source"; cut -c1-150 "$A"
echo "=== ref-sad-fuxi differences"; diff "$A" ref-sad-fuxi/package/CpuFreqProbe.cpp | cut -c1-150 | head -60
echo "=== freq domains in device tree"; grep -n 'freq-domain\|cpufreq' fuxi2/dts/fuxi.dts | cut -c1-120 | head -14
echo "=== clocks rows over time, newest log"
d=$(ls -dt /root/build/fuxi/build/sheng-logs/untagged-* | head -1); echo "$d"
grep -a '^\[clocks\]\|CPUFREQ' "$d"/slots.txt | cut -c1-120 | awk 'NR%15==1' | head -8
