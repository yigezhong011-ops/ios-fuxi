#!/bin/bash
# Full text of the poster denials and of snapshot failures in the newest part of the capture. Read-only.
N=/mnt/e/DSH-Fuxi/logs/carve-plugrant/lscan.txt
T=$(wc -l < $N); echo "lines $T"
echo '--- Kaleidoscope sandbox denials, whole text'
grep -a -E 'Sandbox: (KaleidoscopePoster|PridePosterExt|HelloPosterExt)[A-Za-z]*\(' $N | sed -E 's/\([0-9]+\)/(N)/' | cut -c1-200 | sort | uniq -c | sort -rn | head -14
echo '--- their line numbers'
grep -a -n -E 'Sandbox: (KaleidoscopePoster|PridePosterExt|HelloPosterExt)[A-Za-z]*\(' $N | cut -d: -f1 | tail -14 | tr '\n' ' '; echo
echo '--- theme error'
grep -a 'RunTimeThemeRefForBundleIdentifierAndName' $N | cut -c1-260 | sort | uniq -c | sort -rn | head -4
echo '--- snapshot failure kinds'
grep -a -i -E 'snapshot' $N | grep -a -i -E 'fail|error|timeout|timed out|invalid|unable|could not|cancel|interrupt' | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/U/g; s/[0-9]+/N/g' | cut -c1-170 | sort | uniq -c | sort -rn | head -22
echo '--- poster process exits'
grep -a -E '(Kaleidoscope|Pride|Hello)Poster' $N | grep -a -i -E 'exit|crash|terminat|invalidat|jetsam|launch|spawn fail|Error Domain' | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/U/g; s/[0-9]+/N/g' | cut -c1-170 | sort | uniq -c | sort -rn | head -16
