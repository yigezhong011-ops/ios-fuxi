#!/bin/bash
# Read-only: how the slot log is flushed and when a stuck boot's reset fires.
V=/root/fuxi/ref-fuxi-v2
git -C $V show HEAD:package/BootLog.c | sed -n 680,760p | cut -c1-170
echo "=== slot cadence / persist"
git -C $V show HEAD:package/BootLog.c | grep -n -E 'slot|IOSleep|flush|persist|every|period|interval' | cut -c1-150 | head -40
echo "=== auto image args"
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-t50-auto.sh | cut -c1-200 | head -40
