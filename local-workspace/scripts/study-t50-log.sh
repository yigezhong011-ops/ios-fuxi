#!/bin/bash
# Read-only: the log rows of the last boot, the DPU timing rows, and whether stock DT data for timing@1 is around.
cd /root/fuxi/wall1
ls -la log | cut -c1-90
L=$(ls -d log/* 2>/dev/null | head -1); [ -f log ] && L=log
find log -maxdepth 2 -type f 2>/dev/null | head -8
F=$(find log -type f 2>/dev/null | head -1); [ -z "$F" ] && F=log
echo "file $F"
strings -a "$F" | grep -a -E '^\[(clocks|frames|frame time|display|dpu|cpu|coherence)\]|\[clocks\]|\[frames\]|\[dpu\]|\[display\]|\[te\]|intf|INTF|vsync' | awk '!s[$0]++' | cut -c1-200 | tail -30
echo "== rows"; strings -a "$F" | grep -a -oE '^\[[a-z A-Z0-9_-]+\]' | sort | uniq -c | sort -rn | head -40
echo "== DT"; grep -rIl -E 'timing-switch-command' /mnt/e/DSH-Fuxi/dump/wsl /mnt/e/DSH-Fuxi/read 2>/dev/null | head; ls /root/fuxi | grep -i -E 'dts|dtb|stock' | head
echo "== t50 sheng dpu strings"; strings -a /root/fuxi/t50-kernel.look | grep -E 'sheng-dpu|TE |tear|latch|flush' | cut -c1-120 | sort -u | head -30
