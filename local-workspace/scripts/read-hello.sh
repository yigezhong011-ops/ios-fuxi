#!/bin/bash
# Growth of Metal and poster messages across the Hello run, compared with the capture before it. Read-only.
C=/mnt/e/DSH-Fuxi/logs; K=/mnt/e/DSH-Fuxi/dump/wsl/metal-kinds.py
A=tap2-t50-auto-g7grant; B=hello
python3 -I $K count $C/carve-$A/lscan.txt $C/carve-$A/kinds2.json
python3 -I $K count $C/carve-$B/lscan.txt $C/carve-$B/kinds2.json
python3 -I $K diff $C/carve-$A/kinds2.json $C/carve-$B/kinds2.json | cut -c1-205
N=$C/carve-$B/lscan.txt
echo '--- every refusal naming a shader or function, whole capture counts'
grep -a -E '^native-metal: (render pipeline|compute pipeline|function|library)' $N | sed -E 's/0x[0-9a-f]+/N/g' | cut -c1-200 | sort | uniq -c | sort -rn | head -24
echo '--- Hello poster resources and errors'
grep -a -i -E 'hello' $N | grep -a -i -E 'metal|shader|pipeline|render|library|fail|error|unable|nil|missing' | grep -a -v -E 'PRPosterConfigurable|PBFPosterSnapshotter|Launching|spawned' | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9A-F]{8}-[0-9A-F-]{27}/U/g; s/[0-9]+/N/g' | cut -c1-180 | sort | uniq -c | sort -rn | head -20
