#!/bin/bash
# Growth across the Hello run on the new plugin. Read-only.
C=/mnt/e/DSH-Fuxi/logs; K=/mnt/e/DSH-Fuxi/dump/wsl/metal-kinds.py; B=hello2
python3 -I $K count $C/carve-$B/lscan.txt $C/carve-$B/kinds2.json
python3 -I $K diff $C/carve-hello/kinds2.json $C/carve-$B/kinds2.json | grep -v -E 'no device answer|PBFPosterSnapshotter' | cut -c1-205
N=$C/carve-$B/lscan.txt
echo '--- lines just after the newest Hello lifecycle lines'
L=$(grep -a -n -E 'HelloPosterExte\[|HelloPosterExtension\(' $N | tail -1 | cut -d: -f1); echo "last $L of $(wc -l < $N)"
sed -n "$((L-6)),$((L+6))p" $N | cut -c1-160
echo '--- errors from Metal, CA and Hello code paths'
grep -a -E 'MetalView|HelloPoster\.|CAMetalLayer|nextDrawable|MTLCompiler|makeRenderPipeline|Compiler failed|pipeline state|Failed to create|commandBuffer|Command buffer' $N | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9]+/N/g' | cut -c1-170 | sort | uniq -c | sort -rn | head -20
