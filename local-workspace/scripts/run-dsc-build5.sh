#!/bin/bash
# Instruction-level read of the database init's option branches and the up-to-date check. Read-only.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
python3 -I read-dsc-xref.py $D d 0x1ca8d6ce0 30 70 0x1ca8d7028 0 70 0x1ca8d6d84 0 10 2>&1 | grep -v '^{' | cut -c1-110
echo "== caller options"
python3 -I read-dsc-xref.py $D d 0x1ca89e868 20 8 2>&1 | grep -v '^{' | cut -c1-100 | tail -9
echo "== up-to-date check strings"
python3 -I read-dsc-xref.py $D x 'Pre-migration; data store never ever initialized' 'Pre-migration data store version' 'Post-migration data store version' 'no idea what this data store is' 2>&1 | tail -4 | cut -c1-150
echo "== raw Data: poster store directory names in the latest scan"
python3 -I - <<'EOF'
import re
t = open('/mnt/e/DSH-Fuxi/dump/wsl/study-dsc.sh', errors='replace').read()[:0]
b = open('/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt', 'rb').read().decode('latin1')
for pat in (r'[^\n]{0,60}(?:Pre-migration|Post-migration|never ever)[^\n]{0,60}', r'[^\n]{0,50}PosterBoard[^\n]{0,30}(?:Database|\.db|\.sqlite)[^\n]{0,50}', r'[^\n]{0,80}/Library/Application%20Support/PRB[^\n]{0,80}'):
    print(pat[:30], len(re.findall(pat, b)), re.findall(pat, b)[:4])
EOF
