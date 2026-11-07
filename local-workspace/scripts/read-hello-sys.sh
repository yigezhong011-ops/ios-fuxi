#!/bin/bash
# What HelloPoster ships and which library holds the refused shaders. Reads the local system copy only.
P=/root/fuxi/sys-peek; ls $P | head -12; du -sh $P/* 2>/dev/null | sort -rh | head -5
echo '--- Hello files on disk copies'
find $P -ipath '*HelloPoster*' 2>/dev/null | head -30
echo '--- metallibs mentioning the refused shaders'
find $P -type f -name '*.metallib' 2>/dev/null | wc -l
find $P -type f -name '*.metallib' -print0 2>/dev/null | xargs -0 grep -l -a -E 'pro24MainFragment|lightsMeshFragment' 2>/dev/null | head
echo '--- dyld cache strings'
for f in $(find $P/dsc -maxdepth 2 -type f 2>/dev/null | head -60); do
  n=$(grep -a -c -E 'pro24MainFragment|lightsMeshFragment' "$f" 2>/dev/null || true)
  [ "$n" != "0" ] && echo "$n $f"
done | head
which ipsw dsc_extractor dyld_shared_cache_util 2>/dev/null; ls /root/fuxi/dscan-x86 2>/dev/null | head -3
