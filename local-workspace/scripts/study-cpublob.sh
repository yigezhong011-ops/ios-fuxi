W=/root/fuxi/t50-mine-gpu-cpu; O=/root/fuxi/t50-mine-gpu-120clock
for d in $O $W; do echo "=== $d"; ls -la $d/kernel.blob.elf | cut -c24-; llvm-size --format=berkeley $d/kernel.blob.elf | tail -1; llvm-nm -n $d/kernel.blob.elf | head -14; llvm-objdump -d $d/kernel.blob.elf | sed -n '/^Disassembly/,+12p' | cut -c1-70 | head -16; done
echo "=== patcher entry"; grep -n -E "entry|_start|blob_start|\.text|ENTRY|-Ttext|lld|set_sink|symbol" /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py | cut -c1-170 | head -26
echo "=== smc"; llvm-objdump -d $W/kernel.blob.elf | grep -n -B3 -A3 'smc' | cut -c1-70 | head -20
echo "=== entry fn in source"; grep -n -E 'set_sink|__attribute__|section\(' /mnt/e/DSH-Fuxi/dump/wsl/fuxi-buttons-blob.c | cut -c1-140 | head