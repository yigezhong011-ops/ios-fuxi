L=/mnt/e/DSH-Fuxi/logs; P=/root/build/fuxi/scripts/read-sheng-log.py
cmp $L/carve-autoload/log.bin $L/carve-coh/log.bin | head -1
R=$(python3 -I $P --decode $L/carve-coh/log.bin 2>&1 | tail -1); echo "$R" | cut -c1-150
D=$(echo "$R" | cut -d: -f1)
sed -n 1,16p $D/latest.txt | cut -c1-150
grep -a -A1 '^\[reset\]' $D/latest.txt | cut -c1-170
grep -a '^\[coherence\]\|^\[clocks\]' $D/latest.txt | cut -c1-120
echo "=== msgbuf tail"; tail -c 1800 $D/msgbuf.txt | tr -s '\0' | cut -c1-1800
echo; echo "=== panic-ish"; grep -a -o -E 'panic.{0,140}|Kernel (data|instruction) abort.{0,100}|FUXI120 [a-z0-9]+ [0-9a-f]+ [0-9a-f]+' $D/msgbuf.txt | tail -12