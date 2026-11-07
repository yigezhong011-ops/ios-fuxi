#!/bin/bash
# Where a gallery poster's snapshot stops. Works on the newest stretch of the capture. Read-only.
N=/mnt/e/DSH-Fuxi/logs/carve-plugrant/lscan.txt
echo '--- image error, whole text, newest 3'
grep -a -n 'Image cannot be created from URL' $N | tail -3 | cut -c1-420
echo '--- positions of image error and snapshotter lines (last 8 each)'
grep -a -n 'Image cannot be created from URL' $N | cut -d: -f1 | tail -8 | tr '\n' ' '; echo
grep -a -n 'PBFPosterSnapshotter' $N | cut -d: -f1 | tail -8 | tr '\n' ' '; echo
L=$(grep -a -n 'PBFPosterSnapshotter cleanup is running for .*KaleidoscopePoster' $N | tail -1 | cut -d: -f1)
echo "--- around last Kaleidoscope snapshotter line $L"
sed -n "$((L-45)),$((L+25))p" $N | cut -c1-170
echo '--- PBF and PR error kinds'
grep -a -E '^(<)?(PBF|PR[A-Z]|PF[A-Z])|Poster.*(rror|fail)|snapshot.*(rror|fail)' $N | grep -a -i -E 'error|fail|unable|timeout|timed out|nil|invalid' | grep -a -v -E 'chrono|fs_snapshot|AMSError|url bag|MKMap' | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/U/g; s/[0-9]+/N/g' | cut -c1-170 | sort | uniq -c | sort -rn | head -24
