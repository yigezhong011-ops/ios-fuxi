#!/bin/bash
# Read-only: why t50 answers nohook. Source of the hook, t50 disassembly of the install point, how sheng-autoreset resets.
Q=/root/fuxi/ref-qud; K=/root/fuxi/t50/kernel.macho; S=/mnt/e/DSH-Fuxi/dump/wsl
echo "=== source"; sed -n 90,125p $Q/kernel/QcomXnuUsbDebug.c | cut -c1-110; sed -n 1118,1165p $Q/kernel/QcomXnuUsbDebug.c | cut -c1-110
echo "=== soc value"; grep -n PSCI $Q/soc/Sm8550.h
dis() { local a=$(llvm-nm $K | awk -v s=$1 '$3==s{print $1}'); [ -z "$a" ] && { echo "no $1"; return; }; echo "--- $1 $a"; llvm-objdump -d --start-address=0x$a --stop-address=$(printf '0x%x' $((0x$a + $2))) $K 2>/dev/null | tail -n +7 | cut -c1-90; }
dis _qcom_usb_debug_control_start 200
dis _qcom_usb_debug_control_arm_reboot 100
echo "=== who references PE_halt_restart (adrp+add/ldr/str pairs)"
cat > /tmp/refs.py <<'EOF'
import re,struct,subprocess,sys,bisect
K=sys.argv[1]; T=int(sys.argv[2],16)
out=subprocess.run(['llvm-objdump','--macho','--private-headers',K],capture_output=True,text=True).stdout
segs=[(m[1],int(m[2],16),int(m[4]),int(m[5])) for m in re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)',out)]
d=open(K,'rb').read()
nm=[l.split() for l in subprocess.run(['llvm-nm','-n',K],capture_output=True,text=True).stdout.splitlines()]
code=sorted((int(p[0],16),p[2]) for p in nm if len(p)==3 and p[1] in 'tTsS'); A=[a for a,_ in code]
page=T&~0xfff; off=T&0xfff
for n,v,fo,fs in segs:
    if 'EXEC' not in n: continue
    for o in range(fo,fo+fs-3,4):
        w=struct.unpack_from('<I',d,o)[0]
        if w&0x9f000000!=0x90000000: continue
        pc=v+o-fo
        imm=((w>>5)&0x7ffff)<<2|((w>>29)&3)
        if imm&(1<<20): imm-=1<<21
        if (pc&~0xfff)+(imm<<12)!=page: continue
        rd=w&31
        for k in range(1,9):
            x=struct.unpack_from('<I',d,o+k*4)[0]
            if (x>>5)&31!=rd: continue
            if x&0xffc00000==0x91000000: m=(x>>10)&0xfff
            elif x&0xbfc00000==0xb9400000 or x&0xbfc00000==0xb9000000: m=((x>>10)&0xfff)<<(x>>30)
            else: continue
            if m==off:
                i=bisect.bisect_right(A,pc)-1
                print(hex(pc),code[i][1][:50],'+'+hex(pc-code[i][0]),'insn',hex(x)); break
EOF
python3 /tmp/refs.py $K $(llvm-nm $K | awk '$3=="_PE_halt_restart"{print $1}')
echo "=== sheng-autoreset in sources"
grep -n -E 'sheng-autoreset|autoreset|SYSTEM_RESET|0x84000009|psci' $S/fuxi-buttons-blob.c | cut -c1-140 | head -12
grep -a -c 'sheng-autoreset' $K
grep -rn -E 'sheng-autoreset' /mnt/e/DSH-Fuxi/*.md 2>/dev/null | cut -c1-220 | head -6
python3 $S/find-bl-callers.py $K _PEHaltRestartInternal _host_reboot _reboot_kernel 2>&1 | head -14
