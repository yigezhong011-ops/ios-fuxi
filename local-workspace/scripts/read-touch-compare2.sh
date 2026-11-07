#!/bin/bash
# Read-only: HID driver progress and GPU refusals in the gpu7 boot against the same kind of boot without the patch.
cd /mnt/e/DSH-Fuxi/logs || exit 1
for f in $(ls -t com3-t50-auto-gpu7-*.log | head -1) com3-t50-auto-shot-204244.log com3-t50-auto-shot-203316.log com3-t50-daily-usb-210008.log; do
  echo "== $f $(stat -c%s "$f")"
  grep -a -v SXNU1R "$f" | grep -a -n -E 'NativeHid|AppleUserHID|HIDDrivers|DK: ' | cut -c1-130 | head -10
  echo "-- IOUC refused:"; grep -a -v SXNU1R "$f" | grep -a -oE 'failed MACF in process pid [0-9]+, [A-Za-z0-9_.-]+' | sed -E 's/.*, //' | sort | uniq -c | tr '\n' ';'; echo
  echo "-- FUXI120 lines: $(grep -a -c FUXI120 "$f"); plain lines: $(grep -a -v SXNU1R "$f" | grep -a -c .)"
done
