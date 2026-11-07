#!/bin/bash
# Which boot args does this driver actually parse, and are they PE args or just names?
set -uo pipefail
S=/root/fuxi/drv-fork/NativeAdrenoPublish.cpp
echo "=== PE_parse_boot_argn 调用（参数名与含义）==="
grep -n -A3 'PE_parse_boot_argn' "$S" | head -60 | cut -c1-160
echo
echo "=== 源码里出现的 sheng-gpu-* 字符串 ==="
grep -o '"sheng-gpu-[a-z0-9-]*"' "$S" | sort -u
echo
echo "=== sheng-gpu-mailbox 的上下文（是否 PE 参数）==="
grep -n 'sheng-gpu-mailbox' "$S"
