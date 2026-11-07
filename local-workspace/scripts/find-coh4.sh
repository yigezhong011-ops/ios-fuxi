K=/root/fuxi/t50/kernel.macho
llvm-objdump -d --start-address=0xfffffff00c0444f0 --stop-address=0xfffffff00c045200 $K > /tmp/pw.txt
grep -n -E '#0x538\]' /tmp/pw.txt | cut -c1-90
L=$(grep -n -E 'str.*#0x538\]' /tmp/pw.txt | head -1 | cut -d: -f1); sed -n "$((L-6)),$((L+62))p" /tmp/pw.txt | cut -c1-86