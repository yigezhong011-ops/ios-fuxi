#!/bin/bash
# Read-only: touch-related lines of the gpu7 boot next to the last boots where touch was known or assumed good.
cd /mnt/e/DSH-Fuxi/logs || exit 1
G=$(ls -t com3-t50-auto-gpu7-*.log | head -1)
ls -t com3-t50-auto-shot-*.log com3-t50-daily-usb-*.log 2>/dev/null | head -4
P=$(ls -t com3-t50-daily-usb-*.log com3-t50-auto-shot-*.log 2>/dev/null | head -1)
PAT='[Tt]ouch|TOUCH|[Ff][Tt][Ss]|goodix|Goodix|HIDEvent|digitizer|Digitizer|Multitouch|multitouch|backboardd.*(crash|exit)|SIGABRT|SIGSEGV|panic|Corpse|GPU fault|smmu|SMMU'
for f in "$G" "$P"; do
  echo "== $f $(stat -c%s "$f")"
  grep -a -v SXNU1R "$f" | grep -a -E "$PAT" | sed -E 's/^\[ *[0-9.]+\]:? *//' | cut -c1-120 | sort | uniq -c | sort -rn | head -22
done
echo '== gpu7 last plain lines'
grep -a -v SXNU1R "$G" | grep -a -v '^\s*$' | tail -12 | cut -c1-160
