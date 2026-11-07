cd /root/fuxi/fuxi2
echo "=== 0065 summary"; P=patches/xnu/0065-sweet-smp-psci.patch; wc -l $P; sed -n '1,30p' $P | cut -c1-180
echo "=== 0065 logic"; grep -n -E '^\+.*(PSCI|psci|sheng-smp|cpu_on|CPU_ON|kprintf|printf|mpidr|MPIDR|PE_parse_boot|max_cpus|ncpu|cpu_count|topology)' $P | cut -c1-190 | head -40
echo "=== kernel strings"; K=/root/fuxi/t50-mine/kernel.macho; strings -n 5 $K | grep -i -E 'sweet|smp|cpu_on|psci|secondary|started cpu|cpu %d|cpu%d|cpu start' | cut -c1-140 | sort -u | head -30
echo "=== ADT cpu nodes"; for i in 0 3 4 7; do python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/cpus/cpu$i /root/fuxi/idscan/adt.bin 2>&1 | cut -c1-100 | head -14; done
echo "=== old logs"; cd /mnt/e/DSH-Fuxi/logs; grep -a -l -i -E 'psci|cpu_on|secondary|smp ' com3* *.txt 2>/dev/null | head -8
grep -a -h -i -E 'sweet.*smp|smp:|psci.*(cpu|on)|cpu[ _]?[1-7] (start|up|on)|started cpu|cpu [0-9] (start|up)|secondary' com3* 2>/dev/null | cut -c1-170 | sort | uniq -c | sort -rn | head -20
echo "=== X row source"; cd /root/fuxi/fuxi2/kits/sheng; grep -n -E '"X[0-9] ' BootLog.c ../../package/BootLog.c | cut -c1-220 | head -10
echo "=== lscan: nCPU facts"; L=/mnt/e/DSH-Fuxi/logs/carve-auto120fix/lscan.txt; grep -a -o -i -E '.{0,50}(number of (cpu|core|processor)s?|active processors?|ncpu|cpu_count|logical cores?|perflevel[0-9]|perf levels?|P-?cores?|E-?cores?).{0,60}' $L | cut -c1-140 | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | sort | uniq -c | sort -rn | head -14