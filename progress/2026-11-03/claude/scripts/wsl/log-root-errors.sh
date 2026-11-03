#!/bin/bash
# Root-mount lines of a decoded sheng log (msgbuf and the UFS rows of the slots). Usage: log-root-errors.sh <outdir>
D=$(ls -d "$1"/*/ | head -1)
tr -d '\0' < "$D/msgbuf.txt" | grep -v 'rootvnode is not set' | grep -aiE 'root|ufs|manifest|apfs|mount|verified|window|owner|error|fail|panic|uuid|boot' | head -60 | cut -c1-220
echo "### first lines of msgbuf"
tr -d '\0' < "$D/msgbuf.txt" | head -30 | cut -c1-220
echo "### UFS/data rows in the first and last slot"
grep -E '^(D |U|\[data\]|\[ufs)' "$D/slots.txt" | head -8
