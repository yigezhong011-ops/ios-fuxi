K=/root/fuxi/t50/kernel.macho
llvm-nm -n $K | grep -n -E 'coherenceProbe|publishAndWrapperTest|native_adreno_io_coherent$|native_gpu_coherence_row$|gCoherenceAttempts|_ZN12_GLOBAL__N_1.*dramPage|gpuCopyPage' | cut -c1-110
python3 -I - "$K" <<'PY'
import sys,re,subprocess,struct
K=sys.argv[1]
nm=subprocess.run(['llvm-nm','-n',K],capture_output=True,text=True).stdout.splitlines()
flag=[l for l in nm if l.endswith(' _native_adreno_io_coherent')]; print(flag)
fa=int(flag[0].split()[0],16)
sy=[(int(l.split()[0],16),l.split()[-1]) for l in nm if len(l.split())==3 and l.split()[1] in 'tT']
# find fmt string VA via file search with macho segment map
out=subprocess.run(['llvm-objdump','--macho','--private-headers',K],capture_output=True,text=True).stdout
segs=[]
for m in re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)',out):
    segs.append((m[1],int(m[2],16),int(m[3],16),int(m[4]),int(m[5])))
d=open(K,'rb').read()
def f2v(o):
    for n,v,vs,fo,fs in segs:
        if fo<=o<fo+fs: return v+o-fo
def v2f(a):
    for n,v,vs,fo,fs in segs:
        if v<=a<v+fs: return a-v+fo
print('flag file',hex(v2f(fa) or 0))
s=d.find(b'H d%u/64 a%u'); sv=f2v(s); print('fmt',hex(sv))
# scan exec segments for adrp+add to sv
hits=[]
for n,v,vs,fo,fs in segs:
    if 'TEXT_EXEC' not in n and n!='__TEXT_EXEC': continue
    for o in range(fo,fo+fs-4,4):
        w=struct.unpack_from('<I',d,o)[0]
        if w&0x9f000000==0x90000000:
            pc=v+o-fo
            imm=((w>>29)&3)|(((w>>5)&0x7ffff)<<2)
            if imm&(1<<20): imm-=1<<21
            pg=(pc&~0xfff)+(imm<<12)
            if pg==sv&~0xfff:
                for j in range(1,5):
                    x=struct.unpack_from('<I',d,o+4*j)[0]
                    if x&0xffc00000==0x91000000 and ((x>>10)&0xfff)==(sv&0xfff): hits.append(pc)
print('refs',[hex(h) for h in hits])
open('/tmp/coh.addr','w').write(hex(hits[0]) if hits else '')
PY
A=$(cat /tmp/coh.addr); S=$(printf '0x%x' $((A-0x90))); E=$(printf '0x%x' $((A+0x30)))
llvm-objdump -d --start-address=$S --stop-address=$E $K | cut -c1-90 | tail -n +4