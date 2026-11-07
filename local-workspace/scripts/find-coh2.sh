K=/root/fuxi/t50/kernel.macho; cd /root/fuxi/fuxi2/kits/sheng
echo "=== users of the array"; grep -n 'native_gpu_coherence\b' *.c* ../../drivers/*/* 2>/dev/null | cut -c1-170 | head -12
llvm-nm $K | grep -E ' _native_gpu_coherence$'
echo "=== who reads native_adreno_io_coherent"; grep -rIn 'native_adreno_io_coherent' /root/fuxi/src-adreno740 /root/fuxi/fuxi2/kits /root/fuxi/fuxi2/drivers 2>/dev/null | cut -c1-190 | head -14
echo "=== w22 in the probe"; llvm-objdump -d --start-address=0xfffffff00c0444f0 --stop-address=0xfffffff00c044738 $K | grep -n -E '\b[wx]22\b' | cut -c1-100
echo "=== around the last set"; A=$(llvm-objdump -d --start-address=0xfffffff00c0444f0 --stop-address=0xfffffff00c044738 $K | grep -E '(cset|csel|ccmp|mov|and).*\bw22\b' | tail -1 | cut -d: -f1); echo "last $A"; S=$(printf '0x%x' $((0x$A-0x30))); E=$(printf '0x%x' $((0x$A+0x10))); llvm-objdump -d --start-address=$S --stop-address=$E $K | tail -n +4 | cut -c1-90