#!/bin/bash
# Copy loop and failure handling, then how much the apps boot wrote vs earlier boots. Read-only.
sed -n 1,247p /root/fuxi/staged.patch | cut -c1-140
echo "== who reads the stage counter, anywhere at the pin"
U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git -C $U grep -n -E 'native_staged_apps_(stage|failed|error|files)' $R | sed "s/^$R://" | grep -v 'zzy-staged-system-apps.patch' | cut -c1-170 | head
grep -rn -E 'native_staged_apps|native_owner_data_stage' /mnt/e/DSH-Fuxi/unixnu-build/fuxi --include='*.c' --include='*.cpp' --include='*.h' --include='*.py' --include='*.patch' 2>/dev/null | cut -c1-170 | head
echo "== symbol addresses"
nm /root/fuxi/t50-mine/kernel.macho 2>/dev/null | grep -E 'native_staged_apps_(stage|failed|error|files|dirs|mib|prepare)$|native_owner_data_stage$' | head
echo "== D row by boot"
for n in gpu2 gpu3 daily1 apps2; do
  f=/mnt/e/DSH-Fuxi/logs/twrp-$n.bin
  [ -f "$f" ] || continue
  o=/root/fuxi/log-cmp-$n; rm -rf $o
  python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$f" --out $o >/dev/null 2>&1
  d=$(ls -d $o/*/ | head -1)
  echo "-- $n uptime $(grep -a uptime_s $d/header.txt)"
  grep -a -E '^D st=' $d/slots.txt | sed -n '1p;$p' | cut -c1-110
done
