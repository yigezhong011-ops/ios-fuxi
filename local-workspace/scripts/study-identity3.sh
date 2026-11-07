export MTOOLS_SKIP_CHECK=1
V=/root/fuxi/auto-t50-auto-120fix-p/vol.img
echo == payloads; mdir -i $V ::/EFI/UniXNU/Payloads 2>&1 | head -20
echo == adt-ish; ls -la /root/fuxi/t50* -d 2>/dev/null | head; ls /root/fuxi/t50-mine* 2>/dev/null | head -20; grep -l 'adt' /mnt/e/DSH-Fuxi/dump/wsl/make-t50*.sh | head; grep -n -i 'adt' /mnt/e/DSH-Fuxi/dump/wsl/make-t50-mine.sh 2>/dev/null | cut -c1-200 | head -12
echo == locate iPhone15,2 in vol files
mkdir -p /root/fuxi/idscan; cd /root/fuxi/idscan
mcopy -n -i $V ::/EFI/UniXNU/Payloads/kernel.macho k.bin 2>/dev/null || true
grep -a -b -o 'iPhone15,2\|iPhone 14 Pro' k.bin | head -12; grep -a -c 'iPhone15,2' $V
python3 -I - "$V" <<'PY'
import sys,re
b=open(sys.argv[1],'rb').read()
for p in (b'iPhone15,2',b'iPhone 14 Pro',b'artwork-device-subtype'):
    print(p,[m.start() for m in re.finditer(re.escape(p),b)][:10])
PY
echo == apfs tool usage; sed -n '1,12p' /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py | cut -c1-180