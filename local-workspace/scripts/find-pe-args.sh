#!/bin/bash
# Every PE boot argument the Adreno driver tree reads.
set -uo pipefail
for D in /root/fuxi/drv-fork /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers/Adreno740; do
  [ -d "$D" ] || continue
  echo "=== $D ==="
  grep -rn 'PE_parse_boot_argn' "$D" 2>/dev/null | head -30 | cut -c1-170
  echo "  出现次数: $(grep -rn 'PE_parse_boot_argn' "$D" 2>/dev/null | wc -l)"
done
echo
echo "=== 整个 unixnu-build 里谁解析 sheng-gpu-* ==="
grep -rn 'sheng-gpu-' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers /mnt/e/DSH-Fuxi/unixnu-build/unixnu/kits 2>/dev/null \
  | grep -i 'parse\|boot_arg' | head -20 | cut -c1-170
