#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
echo "=== 文件规模 ==="
wc -l "$P"/probe.c "$P"/loader.c "$P"/start.S "$P"/console.c 2>/dev/null
echo
echo "=== probe.c 里的监控/USB 痕迹 ==="
grep -n 'usb_\|request\|monitor\|probe_main\|MAGIC' "$P/probe.c" | head -20
echo
echo "=== loader.c 里怎么调 probe ==="
grep -n 'probe_main\|display_boost\|loader_boot' "$P/loader.c" | head -10
