#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
for sym in fuxi_usb_debug_start native_legacy_display_late_probe native_legacy_display_probe native_verified_block_root_authorized native_verified_root_probe sheng_pmgr_run; do
  echo "=== $sym ==="
  grep -rn "$sym" "$T" --include='*.h' 2>/dev/null | grep -v '\.cache/xnu-work/bsd/kern/bsd_init.c' | head -2 | cut -c1-190
done
