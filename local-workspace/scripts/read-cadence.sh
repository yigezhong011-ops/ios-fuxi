L=/mnt/e/DSH-Fuxi/logs; P=/root/build/fuxi/scripts/read-sheng-log.py
python3 -I $P --decode $L/carve-auto120fix/log.bin 2>&1 | tail -1 | cut -c1-140
python3 -I $P --decode $L/carve-auto120/log.bin 2>&1 | tail -1 | cut -c1-140
B=/root/build/fuxi/build/sheng-logs
for d in $(ls -dt $B/*/ | head -5); do printf '%s ' $d; head -1 $d/latest.txt; done
F=$(python3 -I $P --decode $L/carve-auto120fix/log.bin 2>&1 | tail -1 | cut -d: -f1)
A=$(python3 -I $P --decode $L/carve-auto120/log.bin 2>&1 | tail -1 | cut -d: -f1)
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-cadence.py $A $F 2>&1 | cut -c1-260
echo == 120fix panel/refresh; grep -a 'FUXI120' $F/msgbuf.txt | head -8
grep -a -h 'scanout prepare' -A1 $F/latest.txt | cut -c1-160
grep -a -i 'refresh' $F/msgbuf.txt | cut -c1-180 | head -8