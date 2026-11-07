#!/bin/bash
# The 'Build payload' section of the saved 11-01 job log, and any gpu addon / plugin lines anywhere in it.
L=/root/fuxi/job.log
S=$(grep -n 'Build payload' $L | grep -v '##\[group\]Run actions' | head -1 | cut -d: -f1)
echo "start line $S"
awk -v s="$S" 'NR>=s && NR<=s+60' $L | cut -c30-230 | grep -vE '^\s*$' | tail -40
echo "### gpu addon / plugin mentions"
grep -niE 'gpuaddon|gpu addon|adreno-metal|turnip|NativeAdrenoMetal' $L | head -15 | cut -c1-220
