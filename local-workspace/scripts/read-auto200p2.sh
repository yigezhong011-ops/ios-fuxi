python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-auto200p2.py /mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt /mnt/e/DSH-Fuxi/logs/carve-auto200p/lscan.txt | cut -c1-200 | head -70
D=/root/build/fuxi/build/sheng-logs/untagged-4ad1902a
echo "=== files"; ls -la $D
echo "=== latest"; cut -c1-220 $D/latest.txt | head -60
echo "=== reset"; grep -a -n -A6 '^\[reset\]' $D/latest.txt | cut -c1-200 | head -20
echo "=== last slot gpu/display rows"; awk '/^#slot /{buf=""} {buf=buf $0 "\n"} END{printf "%s",buf}' $D/slots.txt | cut -c1-220 | head -50
echo "=== msgbuf key"; grep -a -i -n 'FUXI120\|autoreset\|boot_reset\|ngpu\|native_gpu\|overlay\|Logging/Subsystems' $D/msgbuf.txt | cut -c1-200 | head -25