#!/bin/bash
set -uo pipefail
cd /root/hackios
echo "=== fuxi.conf ==="
cat common/devices/fuxi.conf
echo
echo "=== fuxi.platform.c ==="
cat common/devices/fuxi.platform.c
echo
echo "=== redwood.platform.c（参考）==="
ls common/devices/*.platform.c
cat common/devices/redwood.platform.c 2>/dev/null || echo "(没有 redwood 的 platform.c)"
