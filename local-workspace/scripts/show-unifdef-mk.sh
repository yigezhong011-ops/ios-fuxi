#!/bin/bash
set -uo pipefail
MK=$HOME/.local/xnu-linux/src/unifdef/Makefile
echo "=== Makefile 前 25 行 ==="
sed -n '1,25p' "$MK"
