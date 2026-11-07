#!/bin/bash
set -uo pipefail
P=/root/fuxi/0116-kern-exec-inject.patch
echo "=== 补丁里有没有打印/panic ==="
grep -n 'FUXI' "$P" | head -10
echo
echo "=== 补丁头部（看都加了什么）==="
head -40 "$P"
