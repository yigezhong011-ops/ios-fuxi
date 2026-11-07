#!/bin/bash
set -uo pipefail
F=/root/hackios/xnu/files/bsd/dev/redwood_adreno.c
echo "=== RSC / TCS 相关行 ==="
grep -n -iE 'rsc|tcs|cmd_enable|cmd_addr|cmd_data|trigger' "$F" | head -30
