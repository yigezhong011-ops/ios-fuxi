#!/bin/bash
# Read-only: every os_unix.c line in the log by path. Which databases cannot open, and which errno. Is the poster store among them? And the sandbox denials for PosterBoard.
L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
grep -a 'os_unix.c' $L | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g; s/^.*os_unix.c/os_unix.c/' | cut -c1-170 | sort | uniq -c | sort -rn | head -30
echo "=== poster/PosterBoard paths"
grep -a -i -E 'os_unix.c.*(poster|PRB)' $L | cut -c1-220 | head -10
echo "=== denials naming poster"
grep -a -E 'deny\(1\)' $L | grep -i -E 'poster|PRB|353FB615' | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/#/g; s/\([0-9]+\)/(N)/' | cut -c1-210 | sort | uniq -c | sort -rn | head -14
echo "=== posterboard process messages with result/open"
grep -a -E "Failed to open database due to|\] Failed to open|failed to open|sqlite3_open|setup bail" $L | cut -c1-200 | sort | uniq -c | sort -rn | head -10
echo "=== lines right after the first evades line, poster-y"
n=$(grep -an -m1 'evades explanation' $L | cut -d: -f1)
awk -v s=$n 'NR>s-120 && NR<s' $L | grep -a -E -i 'store|sqlite|database|container|posterboard|protection|file:' | cut -c1-180 | head -30
