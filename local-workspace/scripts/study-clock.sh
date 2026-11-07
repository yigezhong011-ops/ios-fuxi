#!/bin/bash
# Read-only: how much of the log complains about dates, certificates and clocks; what upstream records say about the wrong clock.
L=/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt
for p in 'not yet valid' 'NotValidBefore' 'NotBefore' 'errSecCertificateNotValidYet' 'certificate has expired' 'errSecCertificateExpired' 'CSSMERR_TP_NOT_BEFORE' 'clock' '1970-01-0' '1969-12-3' 'date is in the past' 'timeline entries' 'stale' 'expirationDate'; do
  printf '%-34s %s\n' "$p" "$(LC_ALL=C grep -a -c -F "$p" $L)"
done
LC_ALL=C grep -a -E '19(69|70)-[01][0-9]-[0-3][0-9]' $L | cut -c1-170 | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -14
echo "== asteroids"; grep -n -i -E 'rtc|clock.*(1970|2001)|wrong (date|time)|system time|date and time' /root/fuxi/up-latest/docs/.vitepress/device-records/asteroids.toml | cut -c1-700 | head -8
echo "== others"; grep -rIl -i -E 'unixnu-rtc|QcomPmicRtc|PmicRtc' /root/fuxi/up-latest/docs/.vitepress/device-records | head; grep -rIn -i -E 'QcomPmicRtc' /root/fuxi/up-latest --include='*.toml' --include='*.md' --exclude-dir=zh --exclude-dir=device-records | cut -c1-300 | head -8
ls /root/fuxi/up-latest/drivers 2>/dev/null | head -40; git -C /root/fuxi/up-latest ls-files 2>/dev/null | grep -i -E 'rtc' | head
