cd /root/fuxi/unixnu-pin
G=$(git -C /root/fuxi/unixnu-pin ls-files 2>/dev/null | wc -l); echo tracked $G; ls drivers 2>/dev/null | grep -i 'adreno\|gop\|gpu\|gmu' 
echo "=== done= source"; grep -rIn --exclude-dir=.git 'done=%\|offer=%' . 2>/dev/null | cut -c1-230 | head -6
echo "=== freq/dcvs/perf in driver + docs"
grep -rIn --exclude-dir=.git -i 'dcvs\|gx_freq\|perf_level\|perflevel\|gpu_freq\|gpu-freq\|set_gpu\|gmu_freq\|MHz' drivers/*Adreno* docs/zh/drivers/adreno740.md docs/zh/porting/gpu.md 2>/dev/null | cut -c1-210 | head -40
echo "=== X row meaning"; grep -rIn --exclude-dir=.git '"X4 \|"X5 \|"X6 \|X4 H\|X6 M\|X5 S' . 2>/dev/null | cut -c1-260 | head -8
echo "=== cpu freq"; grep -rIln --exclude-dir=.git -i 'cpufreq\|cpu-freq\|EPSS\|osm_l3\|perf_state\|cluster.*freq' drivers docs/zh 2>/dev/null | head -12
ls /root/fuxi/ | grep -i 'adreno\|m2v\|plugin\|gpu-plugin' | head -12