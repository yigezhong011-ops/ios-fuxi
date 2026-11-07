#!/bin/bash
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree
echo "=== 源码里 mix-n-match 的定义与调用 ==="
grep -rn 'mix.n.match\|mix_n_match\|mixAndMatch' "$T" --include='*.c' --include='*.h' --include='*.cpp' 2>/dev/null | head -15
echo
echo "=== payload 内核里相关的字符串 ==="
K=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/payload/stage/EFI/UniXNU/Payloads/kernel.macho
strings -a "$K" 2>/dev/null | grep -i 'mix-n-match\|mix_n_match' | head -8
