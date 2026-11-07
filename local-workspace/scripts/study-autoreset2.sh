#!/bin/bash
# Read-only: the conditions of sheng-autoreset in the source we built, and the arguments in each image.
cd /root/fuxi
sed -n '423p;428p' up-latest/docs/.vitepress/device-records/sheng.toml | grep -o -E '.{0,260}autoreset.{0,320}'
echo "== source"
S=$(find /root/fuxi -maxdepth 7 -name 'BootLog.c' -not -path '*/.git/*' 2>/dev/null | head -8); echo "$S"
F=$(echo "$S" | xargs grep -l 'autoreset' 2>/dev/null | head -1); echo "using $F"
if [ -n "$F" ]; then
  grep -n -E 'autoreset|boot_reset_bootloader|sheng-log|sheng_log' "$F" | cut -c1-150 | head -24
  N=$(grep -n 'autoreset' "$F" | head -1 | cut -d: -f1); sed -n "$((N-12)),$((N+30))p" "$F" | cut -c1-130
fi
echo "== args"
python3 -I - <<'EOF'
import struct,gzip,subprocess,re
for n in ('t50-auto150','t50-auto200','t50-auto-120','t50-mine-gpu-fix'):
    p=f'/mnt/e/DSH-Fuxi/{n}.img'
    b=open(p,'rb').read()
    # header v3: kernel at page 1 (4096)
    m=[x.start() for x in re.finditer(rb'sheng-[a-z]+=',b[:40*1024*1024])][:1]
    if not m: print(n,'no plain args'); continue
    i=m[0]; s=b.rfind(b'\0',0,i)+1; e=b.find(b'\0',i)
    a=b[s:e].decode('latin1')
    print(n,'at',hex(s),'len',len(a))
    print('  first 120:',a[:120])
    print('  last 120 :',a[-120:])
    print('  sheng-log:',re.findall(r'sheng-log=\S+',a),'autoreset:',re.findall(r'sheng-autoreset=\S+',a), 'pos', a.find('sheng-autoreset'))
EOF
echo "== how the boot-args limit reads"
grep -n -E 'BOOT_LINE_LENGTH|boot.?args.*(1024|256|608)|CommandLine\[' -r /root/fuxi/up-latest/docs/porting 2>/dev/null | head -5 | cut -c1-160
