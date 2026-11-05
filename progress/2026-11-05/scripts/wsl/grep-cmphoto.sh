#!/bin/bash
# The actual CMPhoto / hvc1 lines (the -12782 hits above were CarPlay noise).
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-coh2/lscan.txt
echo "=== CMPhotoCompressionSessionAddImage 原始行（前 10 条，去重前）==="
grep -a -m 10 'CMPhotoCompressionSessionAddImage' "$L" | cut -c1-230
echo
echo "=== 去重后（前 10 种）==="
grep -a 'CMPhotoCompressionSessionAddImage' "$L" | sed 's/^[^ ]* //' | sort -u | head -10 | cut -c1-230
echo
echo "=== hvc1 行（去重前 8 条）==="
grep -a -m 8 'hvc1' "$L" | cut -c1-230
echo
echo "=== unableToFinalizeImageDestination 行（前 6 条）==="
grep -a -m 6 'unableToFinalizeImageDestination' "$L" | cut -c1-230
echo
echo "=== 含 GalleryCache 的行（去重，前 8 条）==="
grep -a 'GalleryCache' "$L" | sort -u | head -8 | cut -c1-230
