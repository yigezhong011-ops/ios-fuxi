#!/bin/bash
# Read-only: cpufreq args, docs, and why the P domains read e0 c0.
cd /root/fuxi || exit 1
echo "=== t50 args"; tr ' ' '\n' < t50/args.txt | grep -E 'cpufreq|dcvs|sheng-gpu|sched|cpus' | tr '\n' ' '; echo
echo "=== docs power.md 155-170"; sed -n 155,170p unixnu-pin/docs/zh/porting/power.md | cut -c1-260
echo "=== zzyf anywhere"; find . -maxdepth 6 -iname '*zzyf*' -not -path './logs*' 2>/dev/null | head -10
echo "=== amp patches in fuxi2"; grep -lE 'cluster-type|SCHED_EDGE|CONFIG_SCHED_EDGE' fuxi2/patches/xnu/* 2>/dev/null | head; ls fuxi2/patches/xnu | wc -l
F=fuxi2/package/CpuFreqProbe.cpp; [ -f "$F" ] || F=$(find fuxi2 -name 'CpuFreqProbe.cpp' | head -1)
echo "=== source $F $(wc -l < "$F")"
grep -nE 'CPUFREQ|enable|PE_parse_boot_argn|0x17d9|kDomain|domain\[|struct .*Domain|sheng-cpufreq' "$F" | cut -c1-170 | head -50
echo "=== downloaded upstream sources with CpuFreqProbe"
find . -maxdepth 5 -name 'CpuFreqProbe.cpp' 2>/dev/null | head
