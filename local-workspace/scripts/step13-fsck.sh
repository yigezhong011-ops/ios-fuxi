#!/bin/bash
set -uo pipefail
IMG=/root/fuxi/iosroot.img
for i in 1 2 3; do
  echo "=== repair pass $i ==="
  fsck.hfsplus -f -y "$IMG" 2>&1 | grep -v 'Illegal name' | tail -5
  out=$(fsck.hfsplus -f -n "$IMG" 2>&1 | tail -4)
  echo "--- verify ---"
  echo "$out"
  case "$out" in
    *"appears to be OK"*) echo "CLEAN"; break ;;
  esac
done
ls -lh "$IMG"
echo FSCK_DONE
