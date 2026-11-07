#!/bin/bash
# Read-only: which processes the sandbox refused in the gpu7 wallpaper run, how often, and crash and GPU lines.
cd /mnt/e/DSH-Fuxi/logs || exit 1
f=com3-t50-auto-gpu7-213710.log
stat -c%s "$f"
grep -a -v SXNU1R "$f" > /tmp/g7.txt
echo '== refused, per process'
grep -a -oE 'failed MACF in process pid [0-9]+, [A-Za-z0-9_.-]+' /tmp/g7.txt | sed -E 's/.*, //' | sort | uniq -c | sort -rn
echo '== distinct refused pids'; grep -a -oE 'failed MACF in process pid [0-9]+' /tmp/g7.txt | sort -u | wc -l
echo '== crash and gpu lines'
grep -a -E 'Corpse|Preferences\[|exited due|SIGABRT|SIGTRAP|gpu hang|GPU fault|stall|smmu|SMMU|panic|memorystatus|jetsam|Jetsam' /tmp/g7.txt | cut -c1-120 | sed -E 's/^\[ *[0-9.]+\]:? *//' | sort | uniq -c | sort -rn | head -14
echo '== same counts in the last unpatched shot boot'
grep -a -oE 'failed MACF in process pid [0-9]+, [A-Za-z0-9_.-]+' com3-t50-auto-shot-204244.log | sed -E 's/.*, //' | sort | uniq -c | sort -rn | head
