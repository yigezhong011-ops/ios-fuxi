#!/bin/bash
# Decode a pulled sheng log window and show the newest snapshot's head. Usage: decode-log.sh <bin> <outdir>
B=$1; O=$2
python3 -I - "$B" <<'EOF'
import sys
d = open(sys.argv[1], 'rb').read()
print('nonzero bytes in first MiB:', sum(1 for b in d[:1 << 20] if b), 'magic:', d[:8])
EOF
rm -rf "$O"
python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -5
D=$(ls -d "$O"/*/ 2>/dev/null | head -1)
[ -n "$D" ] || exit 0
cat "$D/header.txt" | grep -E 'boot_id|uptime|slots_written|state'
echo "### latest (head)"; head -40 "$D/latest.txt"
echo "### msgbuf tail"; tr -d '\0' < "$D/msgbuf.txt" | tail -40
