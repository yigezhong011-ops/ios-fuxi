#!/bin/bash
# Read-only: can t50 get a reboot hook? Remaining code of control_start, the hook function if it survived, the autoreset path, how test images are built.
K=/root/fuxi/t50/kernel.macho; S=/mnt/e/DSH-Fuxi/dump/wsl
dis() { local a=$(llvm-nm $K | awk -v s=$1 '$3==s{print $1}'); [ -z "$a" ] && { echo "no $1"; return; }; echo "--- $1 $a"; llvm-objdump -d --start-address=$(printf '0x%x' $((0x$a + $3))) --stop-address=$(printf '0x%x' $((0x$a + $2))) $K 2>/dev/null | tail -n +7 | cut -c19-92; }
dis _qcom_usb_debug_control_start 0x130 0xc4
dis _qcom_usb_reboot_worker 0xa0 0
echo "=== control symbols"; llvm-nm $K | grep -E 'control_(hook|reboot|enabled|started)|halt_restart|platform_smc|diag_reset|autoreset' | cut -c1-100
echo "=== SMC reset constant 0x84000009 in code (movz w0,#9 + movk #0x8400)"
python3 - "$K" <<'EOF'
import re,struct,subprocess,sys,bisect
K=sys.argv[1]
out=subprocess.run(['llvm-objdump','--macho','--private-headers',K],capture_output=True,text=True).stdout
segs=[(m[1],int(m[2],16),int(m[4]),int(m[5])) for m in re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)',out)]
d=open(K,'rb').read()
nm=[l.split() for l in subprocess.run(['llvm-nm','-n',K],capture_output=True,text=True).stdout.splitlines()]
code=sorted((int(p[0],16),p[2]) for p in nm if len(p)==3 and p[1] in 'tTsS'); A=[a for a,_ in code]
for n,v,fo,fs in segs:
    if 'EXEC' not in n: continue
    for o in range(fo,fo+fs-3,4):
        w=struct.unpack_from('<I',d,o)[0]
        if w==0xd4000003:
            pc=v+o-fo; b=[struct.unpack_from('<I',d,o-4*k)[0] for k in range(1,9)]
            if any((x&0xffe0001f)==0x72b08000 or (x&0xffe00000)==0x52800000 and (x>>5)&0xffff==9 for x in b):
                i=bisect.bisect_right(A,pc)-1; print(hex(pc),code[i][1][:60],'+'+hex(pc-code[i][0]))
EOF
echo "=== autoreset string users"; grep -a -b -o 'sheng-autoreset' $K | head -3
grep -n -E 'autoreset' $S/*.sh $S/*.py 2>/dev/null | cut -c1-170 | head -10
echo "=== epss build script"; cut -c1-170 $S/make-t50-epss-test.sh | head -70
echo "=== blob head and size checks"; grep -n -E '0xa23|0xa18|sizeof|BLOB|__attribute__\(\(section|^#if|^#endif|^void |^static .*\(' $S/fuxi-buttons-blob.c | cut -c1-120 | head -50
