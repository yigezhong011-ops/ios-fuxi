B=/root/build/fuxi/build/sheng-logs; D=$B/untagged-a94af048
export MTOOLS_SKIP_CHECK=1; V=/root/fuxi/auto-t50-auto-120fix-p/vol.img
echo "=== all args"; mtype -i $V ::/EFI/UniXNU/unixnu.toml | grep -a '^args' | sed 's/^args = "//; s/"$//' | tr ' ' '\n' | grep -i 'smp\|cpu\|cores\|maxcpus\|cpus\|psci\|ipi\|idle\|wfi\|cluster\|sched\|kt_'
echo "=== msgbuf cpu lines"; grep -a -o -i '.\{0,70\}\(cpu_start\|cpu [0-9]\|cpu[0-9] \|secondary\|ml_processor\|processor_start\|psci\|cpus\b\|ncpu\|smp\).\{0,110\}' $D/msgbuf.txt | cut -c1-190 | head -25
echo "=== serial earliest lines"; L=/mnt/e/DSH-Fuxi/logs; f=$(ls -t $L/com3-t50-auto-120fix-p-* | head -1); grep -a -i -n 'cpu\|smp\|psci\|secondary' $f | cut -c1-170 | head -30
echo "=== lscan cpu facts"; N=/root/fuxi/auto120/new.txt; grep -a -i -E 'hw\.(ncpu|physicalcpu|logicalcpu|activecpu)|activeProcessorCount|ncpu|processorCount|cpu count|cores? online' $N | cut -c1-170 | sort | uniq -c | sort -rn | head -12
echo "=== slots rows containing cpu"; last=$(grep -a -n '^#slot ' $D/slots.txt | tail -1 | cut -d: -f1); tail -n +$last $D/slots.txt | grep -a -i -E 'cpu|smp|idle|sched|per-cpu|core' | cut -c1-260 | head -20
echo "=== ADT cpus"; python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/cpus /root/fuxi/idscan/adt.bin 2>&1 | cut -c1-110 | head -8
python3 -I - /root/fuxi/idscan/adt.bin <<'PY'
import re,sys
b=open(sys.argv[1],'rb').read()
print('cpu names',[m.group().decode() for m in re.finditer(rb'cpu\d\b',b)][:16])
PY
echo "=== source"; cd /root/fuxi/fuxi2; grep -rIln --exclude-dir=.git -E 'sheng-smp|cpu_start|ml_processor_register|offline-legacy-cpu-present' kits package patches scripts 2>/dev/null | head -12
grep -rIn --exclude-dir=.git -E 'sheng-smp|offline-legacy-cpu-present' kits package patches docs 2>/dev/null | cut -c1-240 | head -14
grep -n -i 'sheng-smp\|smp\|secondary\|八核\|8 core\|8 CPU' /root/fuxi/unixnu-pin/docs/zh/devices/sheng.md /root/fuxi/unixnu-pin/docs/zh/porting/power.md | cut -c1-230 | head -14