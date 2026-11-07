L=/mnt/e/DSH-Fuxi/logs
W=/root/fuxi/auto120; mkdir -p $W
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-auto200p.py $L/carve-auto200p/lscan.txt $L/carve-auto120/lscan.txt $W/new.txt | cut -c1-200 | sed -n '1,40p'
echo "=== poster store lines"
grep -a -n -i 'data store\|PRBPoster\|Kicking off\|buildDataStore\|setup database' $W/new.txt | cut -c1-240 | head -30
echo "=== dates seen"
grep -a -o -E '\b(19[67][0-9]|202[0-9])-[0-9]{2}-[0-9]{2} [0-9:]{8}' $W/new.txt | cut -c1-4 | sort | uniq -c
echo "=== sheng log"
python3 -I /root/build/fuxi/scripts/read-sheng-log.py --decode $L/carve-auto120/log.bin 2>&1 | tail -1
D=$(ls -dt /root/build/fuxi/build/sheng-logs/*/ | head -1); echo $D
sed -n '1,22p' $D/latest.txt | cut -c1-170
grep -a -n -A1 '^\[reset\]' $D/latest.txt | cut -c1-170
grep -a '^W[0-9]* t=' $D/latest.txt | tail -12 | cut -c1-80
python3 -I - "$D/latest.txt" <<'PY'
import re,sys
t=[float(x) for x in re.findall(r'(?m)^W\d+ t=([\d.]+)s',open(sys.argv[1],errors='replace').read())]
if len(t)>2:
    print('swap rows',len(t),'span %.3fs rate %.1f/s'%(t[-1]-t[0],(len(t)-1)/(t[-1]-t[0])))
PY
grep -a -c 'FUXI120' $D/msgbuf.txt
grep -a -i 'panic\|tear\|dsi.*err\|fifo.*err\|underrun' $D/msgbuf.txt | cut -c1-170 | head -10