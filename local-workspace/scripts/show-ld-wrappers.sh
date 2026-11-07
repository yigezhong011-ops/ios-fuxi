#!/bin/bash
set -uo pipefail
P=$HOME/.local/xnu-linux
echo "=== $P/bin/ld ==="
if [ -f "$P/bin/ld" ]; then head -30 "$P/bin/ld"; else echo "（不存在）"; fi
echo
echo "=== /opt/unixnu-linux/CommandLineTools/usr/bin/xnu-host-cc ==="
F=/opt/unixnu-linux/CommandLineTools/usr/bin/xnu-host-cc
if [ -f "$F" ]; then head -25 "$F"; else echo "（不存在）"; fi
echo
echo "=== 系统 ld ==="
ls -l /usr/bin/ld* 2>/dev/null | head -4
