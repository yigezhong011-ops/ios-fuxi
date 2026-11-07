cd /root/fuxi
C=fuxi2/kits/sheng/CpuFreqProbe.cpp
sed -n '1,27p;38,155p' $C | cut -c1-175
echo "=== mode in kernel"; strings -n 4 t50-mine/kernel.macho | grep -E 'CPUFREQ|sheng-cpufreq|cpufreq-cap|cpu_idle|native_cpufreq' | sort -u | head
echo "=== other reports of d1:e"; grep -rIl --exclude-dir=.git -E 'd1:e[01]' /mnt/e/DSH-Fuxi/*.md fuxi2/docs unixnu-pin/docs ref-sad-fuxi ref-zizhan 2>/dev/null | head
grep -rIhn --exclude-dir=.git -E 'd1:e[01]' /mnt/e/DSH-Fuxi/*.md unixnu-pin/docs 2>/dev/null | cut -c1-260 | head -8
echo "=== sheng doc device line"; grep -n -E 'domain 1 between|cpufreq=4|CpuFreqProbe|EPSS' unixnu-pin/docs/devices/sheng.md | cut -c1-300 | head -10
echo "=== newest upstream CpuFreqProbe here"; ls -la unixnu-pin/kits/sheng/CpuFreqProbe.cpp unixnu-pin/package/CpuFreqProbe.cpp /root/build/fuxi/kits/sheng/CpuFreqProbe.cpp /root/build/unixnu/kits/*/CpuFreqProbe.cpp 2>/dev/null | cut -c24-
wc -l /root/build/fuxi/kits/sheng/CpuFreqProbe.cpp 2>/dev/null