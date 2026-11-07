#!/bin/bash
# Does the dyld shared cache carry a CMPhoto HEVC encoder plugin?
set -uo pipefail
D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
echo "=== 搜编码器插件类名（整个 cache，约 3 GB）==="
for pat in 'CMPhotoHEIF' 'HEIFEncoder' 'HEVCEncoder' 'CMPhotoCompressionSession' 'CMPhotoDecompressor'; do
  n=$(grep -ac "$pat" "$D"/dyld_shared_cache_arm64* 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
  printf '  %-28s %s\n' "$pat" "$n"
done
echo
echo "=== 具体命中（前 12 个不同字符串）==="
grep -aoh 'CMPhoto[A-Za-z]*HE[A-Za-z]*\|HEVC[A-Za-z]*Encoder\|[A-Za-z]*HEIFEncoder[A-Za-z]*' "$D"/dyld_shared_cache_arm64* 2>/dev/null | sort -u | head -12
