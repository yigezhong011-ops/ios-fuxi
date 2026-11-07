#!/bin/bash
# Pull the GPU-relevant lines out of a decoded sheng log (all snapshots of the boot).
D=$(ls -d /root/fuxi/logs-1103/*/ | head -1)
S=$D/slots.txt
echo "### header"; cat $D/header.txt
echo "### gpu clients over time"; grep -E '^\[gpu clients\]' $S | sort | uniq -c | sort -rn | head -8
echo "### metal askers"; grep -E '^\[metal askers\]' $S | sort -u | tail -3
echo "### W/Wb warnings (unique)"; grep -E '^Wb? ' $S | sort | uniq -c | sort -rn | head -30
echo "### P lines (unique)"; grep -E '^P[0-9]b? ' $S | sort -u | head -20
echo "### client text / errors"; grep -aiE 'client text|refus|invalid|unsupported|fail' $S | grep -vE '^(\[fence|\[scanout|prepare)' | sort | uniq -c | sort -rn | head -30
echo "### msgbuf tail"; tr -d '\0' < $D/msgbuf.txt | grep -aiE 'gpu|metal|adreno|widget|panic|error' | tail -40
