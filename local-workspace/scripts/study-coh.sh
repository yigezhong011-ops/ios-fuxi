cd /root/fuxi; B=/root/build/fuxi/build/sheng-logs
echo "=== source"; grep -rIln --exclude-dir=.git --exclude-dir=out -E 'coherence' src-adreno740 unixnu-pin/drivers/Adreno740 fuxi2/drivers fuxi2/kits unixnu-pin/docs/zh/drivers 2>/dev/null | head -10
F=$(grep -rIl --exclude-dir=.git --exclude-dir=out -E '\[coherence\]|coherence ' src-adreno740 fuxi2/kits fuxi2/drivers 2>/dev/null | head -1); echo "FILE $F"
grep -rIn --exclude-dir=.git --exclude-dir=out -E 'PE_parse_boot_argn\("[^"]*(coher|cache|snoop|io-?cc)[^"]*"' src-adreno740 fuxi2/kits fuxi2/drivers unixnu-pin/drivers 2>/dev/null | cut -c1-200 | head
grep -rIn --exclude-dir=.git --exclude-dir=out -i -E 'coherence.*(on|off)|-> on|hysteresis|gCoherent|coherent_|fence pauses' src-adreno740 fuxi2/kits fuxi2/drivers 2>/dev/null | cut -c1-220 | head -24
echo "=== docs"; grep -rIn -i 'coheren' unixnu-pin/docs/zh/drivers/adreno740.md unixnu-pin/docs/zh/porting/gpu.md unixnu-pin/docs/zh/devices/sheng.md unixnu-pin/docs/devices/sheng.md 2>/dev/null | cut -c1-320 | head -18
echo "=== kernel"; strings -n 5 t50-mine/kernel.macho | grep -i -E 'coheren' | cut -c1-130 | sort -u | head -18
echo "=== across runs"; for d in untagged-4ad1902a untagged-64a63a760 untagged-a94af048 untagged-45d8d0fd; do printf '%s ' $d; grep -a '^\[coherence\]' $B/$d/latest.txt | cut -c1-96; grep -a '^\[gpu methods\]' $B/$d/latest.txt | grep -o ' 5:[^ ]*'; done
echo "=== flip history in slow run"; grep -a '^\[coherence\]' $B/untagged-a94af048/slots.txt | sed -E 's/\| .*//' | awk 'NR%15==1' | cut -c1-70
