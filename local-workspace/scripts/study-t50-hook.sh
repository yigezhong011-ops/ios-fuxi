#!/bin/bash
# Read-only: how t50-mine was built and how the buttons blob is placed into the kernel.
cd /mnt/e/DSH-Fuxi/dump/wsl
ls -t make-t50* make-t36* patch-t*.py 2>/dev/null | head -20
echo "== make-t50-mine?"; grep -l -E 't50-mine\.img|OUT=.*t50-mine' *.sh | head
echo "== sad backlight"; grep -n -E 'fuxi-backlight|dsi|DSI|0xae94000|Fuxi|fuxi' /root/fuxi/ref-sad-fuxi/package/AppleARMBacklight.cpp | cut -c1-140 | head -50
echo "== blob head"; sed -n 1,44p fuxi-buttons-blob.c | cut -c1-200
sed -n 150,335p fuxi-buttons-blob.c | grep -n -E 'static void|^void|ADDR_|thread|sleep|delay|DELAY' | cut -c1-150 | head -40
echo "== zizhan rest"; sed -n 70,110p /root/fuxi/ref-zizhan/2026-11-01-120hz-and-cadence.md | cut -c1-420
