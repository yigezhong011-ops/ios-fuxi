cd /root/fuxi/fuxi2/kits/sheng
echo "=== timeline writer"; grep -n -E 'swap timeline|offer=|done=' BootLog.c TouchProbe.cpp | cut -c1-200 | head -8
grep -n -B2 -A10 'swap timeline' TouchProbe.cpp | cut -c1-210 | head -40
echo "=== sections in latest.txt"; D=/root/build/fuxi/build/sheng-logs/untagged-a94af048; grep -a -n '^\[' $D/latest.txt | cut -c1-60 | head -50
echo "=== freq rows"; grep -a -n -i 'cpufreq\|dcvs\|MHz\|freq\|gpu lvl\|level' $D/latest.txt | cut -c1-230 | head -30
echo "=== msgbuf freq"; grep -a -o -i '.\{70\}\(dcvs\|cpufreq\|gmu\).\{100\}' $D/msgbuf.txt | cut -c1-200 | head -14
echo "=== Args parsed in kits"; grep -rIl 'sheng-gpu-dcvs\|sheng-cpufreq' /root/fuxi/fuxi2 /root/build/unixnu/drivers /root/fuxi/unixnu-pin/drivers --include=*.c --include=*.cpp --include=*.h --include=*.md 2>/dev/null | head -8
K=/root/fuxi/t50-mine/kernel.macho; for w in sheng-gpu-dcvs sheng-cpufreq sheng-gpu-dcvs-boost-ms sheng-cpufreq-boost-ms sheng-cpufreq-min cpufreq; do printf '%-26s %s\n' $w "$(grep -a -c "$w" $K)"; done
strings -n 6 $K | grep -i 'dcvs\|cpufreq' | cut -c1-140 | sort -u | head -30