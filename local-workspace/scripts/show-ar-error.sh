#!/bin/bash
set -uo pipefail
L=/root/ci3.log
echo "=== ar 失败上下文（595-625）==="
sed -n '595,625p' "$L" | cut -c1-220
