#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
for sym in NativeAdrenoGpuContextPagetable boot_log_crash_collect native_owner_root_accepted \
           native_touch_edge_stats native_ufs_integrity_failures native_ufs_verified_blocks \
           native_ufs_verify_ticks native_virtio_verified_blocks; do
  echo "=== $sym ==="
  grep -rhn "$sym" "$T/kits/sheng" "$T/drivers" "$T/.cache/xnu-work/osfmk" --include='*.c' --include='*.cpp' --include='*.h' 2>/dev/null \
    | grep -E 'extern|^ *(int|void|bool|unsigned|uint|const)' | head -2 | sed 's/^ *//' | cut -c1-160
done
