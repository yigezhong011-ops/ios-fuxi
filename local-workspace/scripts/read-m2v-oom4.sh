#!/bin/bash
# Read only: the newest boot only. Its args, GPU related errors, and what the Pride process said.
export MTOOLS_SKIP_CHECK=1
N=/mnt/e/DSH-Fuxi/logs/carve-m2vs-pride/lscan.txt; A=/root/fuxi/src-adrenometal
sed -n '25291635,$p' $N > /tmp/b.txt; wc -l < /tmp/b.txt
echo '--- boot args of the images'
for d in plug-t50-auto-m2vs plug-t50-auto-sb3; do V=/root/fuxi/$d/vol.img; echo "$d: $(mdir -/ -b -i $V ::/ 2>/dev/null | grep -c .) files"; done
grep -a -n -E 'sheng-[a-z-]+=' /mnt/e/DSH-Fuxi/logs/com3-t50-auto-m2vs-163428.log | head -3 | cut -c1-400
echo '--- metal words, newest boot'
grep -a -i -E 'metal|mtl|shader|pipeline|drawable|turnip|vulkan|vk_|spir|nir_|lower|function constant|poster.*(error|fail)|pride.*(error|fail)' /tmp/b.txt | grep -v -E 'MTLCompilerService|no device answer|translation|frames.trace|Metal.framework/|com.apple.Metal$' | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9]+/N/g' | cut -c1-140 | sort | uniq -c | sort -rn | head -40
echo '--- pride lines'
grep -a -n -i -E 'pride' /tmp/b.txt | sed -E 's/0x[0-9a-f]+/N/g' | cut -d: -f2- | cut -c1-130 | sort | uniq -c | sort -rn | head -25
echo '--- plugin commits since the old pin'
git -C $A log --oneline 7e0d3d2..ce63701 2>/dev/null | wc -l
git -C $A log --format='%h %s' 7e0d3d2..ce63701 2>/dev/null | grep -i -E 'constant|fragment|black|poster|pride|hello|mesh|tile|depth|load action|store|memoryless|sample|argument|indirect|heap' | cut -c1-110 | head -40
