#!/bin/bash
set -uo pipefail
T=/root/ux2/fuxi/tree
echo "=== 这 4 个符号的真实声明 ==="
for sym in native_verified_block_root_authorized native_verified_block_volume_device native_verified_root_probe sheng_pmgr_run; do
  echo "--- $sym ---"
  grep -rn "$sym" "$T/.cache/xnu-work" --include='*.h' 2>/dev/null | head -3 | cut -c1-180
done
