#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon53/boot.log
echo "=== GPU 相关错误/故障 ==="
tr -d '\000' < "$L" | grep -a -iE 'FUXI GPU|adreno|a6xx|fault|hang|timeout|quarantin' | tail -20
