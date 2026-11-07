#!/bin/bash
# After the grant: what the gallery's poster processes did. Read-only.
C=/mnt/e/DSH-Fuxi/logs; N=$C/carve-plugrant/lscan.txt
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/metal-kinds.py count $N $C/carve-plugrant/kinds.json
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/metal-kinds.py diff $C/carve-ab2-t50-auto-g7plug/kinds.json $C/carve-plugrant/kinds.json | cut -c1-125
echo '--- newest Kaleidoscope, Pride, Hello lines, excluding snapshotter chatter'
grep -a -n -E 'KaleidoscopePoster|PridePosterExtension|HelloPosterExtension' $N | grep -a -v -E 'PBFPosterSnapshotter|RBSAssertion' | tail -25 | cut -c1-190
L=$(grep -a -n 'KaleidoscopePoster' $N | tail -1 | cut -d: -f1)
echo "--- around last Kaleidoscope line, $L"
sed -n "$((L-12)),$((L+12))p" $N | cut -c1-150
