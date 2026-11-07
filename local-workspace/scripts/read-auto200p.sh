set -e
W=/root/fuxi/auto200p; mkdir -p $W/log
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-auto200p.py /mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt /mnt/e/DSH-Fuxi/logs/carve-auto200p/lscan.txt $W/new.txt
echo "=== boot log"
python3 -I /root/build/fuxi/scripts/read-sheng-log.py --help 2>&1 | head -12 || true
cd $W/log; python3 -I /root/build/fuxi/scripts/read-sheng-log.py --decode /mnt/e/DSH-Fuxi/logs/carve-auto200p/log.bin 2>&1 | tail -12 || true
ls -R $W/log | head -20