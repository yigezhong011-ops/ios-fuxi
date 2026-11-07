K=/root/fuxi/t50/kernel.macho
echo "=== who branches to the patched spot"; llvm-objdump -d --start-address=0xfffffff00c0444f0 --stop-address=0xfffffff00c045100 $K | grep -E '0xfffffff00c044(730|72c|728|6d0|6c8|6e4)\b' | cut -c1-110 | head -14
echo "=== the second site"; llvm-objdump -d --start-address=0xfffffff00c044f90 --stop-address=0xfffffff00c045040 $K | tail -n +4 | cut -c1-96 | head -48
echo "=== attempt loop: gCoherenceAttempts at 0xfffffff00c257538"; python3 -I /mnt/e/DSH-Fuxi/dump/wsl/find-coh-readers.py $K 0xfffffff00c257538 | cut -c1-110
echo "=== cmp #8 in the function"; llvm-objdump -d --start-address=0xfffffff00c0444f0 --stop-address=0xfffffff00c045100 $K | grep -n -E 'cmp\s+[wx][0-9]+, #0x(7|8)\b|#0x8$' | cut -c1-100 | head -12