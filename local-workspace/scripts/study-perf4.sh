B=/root/build/fuxi/build/sheng-logs
for D in $B/untagged-64a63a760 $B/untagged-a94af048; do echo "######## $(basename $D)"
grep -a -E '^\[(clocks|coherence|fence wait|scanout wait|gpu methods|gpu methods\+|gpu clients|wait port)\]' $D/latest.txt | cut -c1-520
done
echo "=== clocks over time, fix run"; grep -a '^\[clocks\]' $B/untagged-a94af048/slots.txt | sed -E 's/^\[clocks\] //' | awk 'NR%25==1' | cut -c1-140 | head -9
echo "=== source"; C=/root/fuxi/fuxi2/kits/sheng/CpuFreqProbe.cpp; wc -l $C
grep -n -E 'd%d|e%d|"CPUFREQ|enable|EPSS|0x17d9|LUT|domain' $C | cut -c1-200 | head -45