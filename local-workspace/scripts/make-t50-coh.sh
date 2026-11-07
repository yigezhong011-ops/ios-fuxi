#!/bin/bash
# t50-auto-120clock-p with the IO coherence flag on even when the boot probe's precondition failed. Two instructions in coherenceProbe (inlined in publishAndWrapperTest). Temp boot only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; SRC=/root/fuxi/auto-t50-auto-120clock-p; W=/root/fuxi/auto-t50-auto-coh
export MTOOLS_SKIP_CHECK=1
K=/root/fuxi/t50/kernel.macho
echo "=== x25 setup"; llvm-objdump -d --start-address=0xfffffff00c0443bc --stop-address=0xfffffff00c044738 $K | grep -n -E '\bx25\b' | cut -c1-100 | head -12
llvm-nm $K | grep -E ' _native_adreno_io_coherent$'
llvm-objdump -d --start-address=0xfffffff00c0443bc --stop-address=0xfffffff00c044738 $K | grep -A2 -E 'adrp\s+x25' | cut -c1-100 | head -6
echo "=== k[7] readers"; grep -n 'native_gpu_coherence\[' /root/fuxi/fuxi2/kits/sheng/*.c* | cut -c1-120 | head
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp $SRC/vol.img vol.img
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.old
python3 -I - <<'PY'
import re, struct, subprocess
K='kernel.old'
out=subprocess.run(['llvm-objdump','--macho','--private-headers',K],capture_output=True,text=True).stdout
segs=[(int(m[2],16),int(m[4]),int(m[5])) for m in re.finditer(r'segname (\S+)\n\s+vmaddr (0x[0-9a-f]+)\n\s+vmsize (0x[0-9a-f]+)\n\s+fileoff (\d+)\n\s+filesize (\d+)',out)]
def v2f(a):
    for v,fo,fs in segs:
        if v<=a<v+fs: return a-v+fo
    raise SystemExit('no segment')
d=bytearray(open(K,'rb').read())
for va,old,new in ((0xfffffff00c044730,0xb9001f56,0x52800028),(0xfffffff00c044734,0xb9000336,0xb9000328)):
    o=v2f(va); assert struct.unpack_from('<I',d,o)[0]==old, hex(va)
    struct.pack_into('<I',d,o,new); print('patched',hex(va),hex(o))
open('kernel.macho','wb').write(d)
PY
cmp -l kernel.old kernel.macho | wc -l
llvm-objdump -d --start-address=0xfffffff00c04472c --stop-address=0xfffffff00c04473c kernel.macho | tail -n 4 | cut -c1-80
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho >/dev/null
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.back; cmp kernel.back kernel.macho; rm -f kernel.back
python3 -I $S/repack-with-vol.py $E/t50-mine.img vol.img $E/t50-auto-coh.img >/dev/null
python3 -I $S/compare-loaders.py $E/t50-auto-coh.img | tail -1
sha256sum $E/t50-auto-coh.img | cut -c1-16