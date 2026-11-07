#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon28/boot.log
echo "=== SpringBoard 前后 ==="
tr -d '\000' < "$L" | grep -a -n -A6 'exec SpringBoard' | head -30
echo
echo "=== scene / FBScene / frontboard ==="
tr -d '\000' < "$L" | grep -a -i 'scene\|frontboard\|FBApplication\|watchdog' | tail -12
echo
echo "=== SpringBoard 崩溃？ ==="
tr -d '\000' < "$L" | grep -a -c 'CRASH SpringBoard' || true
