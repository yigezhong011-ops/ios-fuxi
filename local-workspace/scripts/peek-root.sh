#!/bin/bash
# Read files out of the local root volume image: the app list and the PosterBoard executable. The image is only read.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
W=/mnt/e/DSH-Fuxi/dump/root-peek; mkdir -p "$W"
cat /mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.json | cut -c1-300 | head -12
[ -s "$W/list.txt" ] || 7z l -ba "$I" > "$W/list.txt" 2>"$W/list.err"
wc -l "$W/list.txt"; head -3 "$W/list.err" | cut -c1-150
awk '{print $NF}' "$W/list.txt" | grep -E '(^|/)Applications/[^/]+\.app$' | sed 's#.*/Applications/##' | sort -u | tr '\n' ' ' | cut -c1-2500; echo
grep -E '/PosterBoard$|PosterBoard\.app/PosterBoard' "$W/list.txt" | cut -c1-140 | head
P=$(awk '{print $NF}' "$W/list.txt" | grep -E 'Applications/PosterBoard\.app/PosterBoard$' | head -1)
echo "path: $P"
if [ -n "$P" ]; then
  7z e -y -bd -o"$W/bin" "$I" "$P" >/dev/null 2>&1
  ls -la "$W/bin/" | cut -c24-100
  file "$W/bin/PosterBoard" | cut -c1-160
  strings -a "$W/bin/PosterBoard" | grep -c PBFModal
  strings -a "$W/bin/PosterBoard" | grep -E -i 'dataStore|invalid|PBFModal' | cut -c1-140 | head -24
fi
which llvm-objdump objdump aarch64-linux-gnu-objdump rabin2 r2 ipsw 2>/dev/null
python3 -c 'import capstone; print("capstone", capstone.__version__)' 2>&1 | tail -1
