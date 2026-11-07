L=/mnt/e/DSH-Fuxi/logs; P=/root/build/fuxi/scripts/read-sheng-log.py
R=$(python3 -I $P --decode $L/carve-autoload/log.bin 2>&1 | tail -1); echo "$R" | cut -c1-150
D=$(echo "$R" | cut -d: -f1)
echo "=== uptime and reset"; sed -n 1p $D/latest.txt; grep -a -A1 '^\[reset\]' $D/latest.txt | cut -c1-170
grep -a '^\[clocks\]' $D/latest.txt | cut -c1-130
echo "=== msgbuf end"; tail -c 900 $D/msgbuf.txt | tr -s '\0' | cut -c1-900
echo; echo "=== FUXI + panic"; grep -a -o -E 'FUXI120 c[0-7] [0-9a-f]+ [0-9a-f]+|panic\(.{0,120}|Kernel data abort.{0,100}|Debugger.{0,60}' $D/msgbuf.txt | head -14
echo "=== swap"; python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-cadence.py $D 2>&1 | cut -c1-200 | sed -n '2,14p'