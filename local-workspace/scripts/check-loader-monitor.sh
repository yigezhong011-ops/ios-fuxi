#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-loader/loader.c
grep -n 'probe_main' "$F" | head -5
echo "---"
grep -n 'probe_touch_up' "$F" | head -5
echo "---"
grep -n 'loader_boot' "$F" | head -5
echo "=== probe_main 内部是否依赖 boot-arg ==="
grep -n 'fuxiprobe\|PE_parse_boot_argn' /root/ios-fuxi/shim/fuxi-probe/probe.c | head -8
