#!/bin/bash
# Extract HelloPoster and find the refused shaders with 7z, on the local system image only.
I=/root/fuxi/sys-peek/systemos.img; O=/root/fuxi/hello-look; mkdir -p $O; cd $O
Z=$(command -v 7z || command -v 7zz || command -v 7za || command -v p7zip); echo "tool $Z"
[ -n "$Z" ] || exit 0
$Z l -ba "$I" > list.txt 2>&1; wc -l list.txt; head -3 list.txt | cut -c1-120
grep -a -c metallib list.txt
grep -a -E 'HelloPoster' list.txt | cut -c54- | head -20
$Z x -y -bso0 -bsp0 -o"$O/x" "$I" '*HelloPoster.framework*' -r >/dev/null 2>&1
find x -type f | wc -l
find x -type f -name '*.metallib' | head
for f in $(find x -type f | head -40); do n=$(strings -n 6 "$f" 2>/dev/null | grep -c -E 'Fragment|Vertex|metallib|MTL|CAMetal'); [ "$n" != "0" ] && echo "$n $f"; done | sort -rn | head -10
for f in $(find x -type f -name '*.metallib'); do echo "== $f"; strings -n 5 "$f" | grep -E 'Fragment|Vertex|Kernel|Compute' | sort -u | head -30; done
