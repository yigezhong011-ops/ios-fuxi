#!/bin/bash
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree
U=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
echo "=== 全树搜 'mix-n-match policy' ==="
grep -rn 'mix-n-match policy\|mix_n_match policy' "$U" 2>/dev/null | head -10
echo
echo "=== 全树搜 'mix-n-match'（任意文件）==="
grep -rIn 'mix-n-match' "$T/build" 2>/dev/null | head -10
echo
echo "=== payload 目录里的文件 ==="
ls -l "$U/out/fuxi/payload/stage/EFI/UniXNU/Payloads/" 2>/dev/null
echo
echo "=== ADT 里有没有 mix 相关键 ==="
strings -a "$U/out/fuxi/payload/stage/EFI/UniXNU/Payloads/kernel.macho.adt" 2>/dev/null | grep -i 'mix\|img4\|trust' | head -10
