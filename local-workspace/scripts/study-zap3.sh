#!/bin/bash
# Read-only: compare the diagnostic rows of a good boot with hang boots, around the zap marks.
G=/root/fuxi/cad-ab/untagged-6798de11ea/slots.txt
echo "=== good boot, frames around the zap"
sed -n 233,345p $G | cut -c1-110
echo "=== logs with Z7 as their last Z mark"
for f in $(grep -rl -a -E 'Z[0-9]+/[0-9]+ i' /mnt/e/DSH-Fuxi/logs /root/fuxi --include='*.txt' --include='*.log' 2>/dev/null | head -400); do
  l=$(grep -a -o -E 'Z[0-9-]+/[0-9]+ i[^ ]+ m[^ ]+ a[^ ]+ s[^ ]+ f[^ ]+' "$f" | tail -1)
  case "$l" in Z9*) ;; *) echo "$f | $l | lines $(wc -l < "$f")";; esac
done | head -30
echo "=== counts"
grep -rl -a -E 'Z9/4' /root/fuxi /mnt/e/DSH-Fuxi/logs --include='*.txt' --include='*.log' 2>/dev/null | wc -l
