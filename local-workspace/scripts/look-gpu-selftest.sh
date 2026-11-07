#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/xnu/fuxi-adreno/fuxi_adreno.c
echo "=== 自检 / ready 状态 / stage 逻辑 ==="
grep -n -E 'fg_state|gpu_stage|self-test|fg_fail|zap|0xf07|ready' "$F" | head -30
echo
echo "=== fg_init / 服务发布 ==="
grep -n -A12 'fg_init_thread\|fg_init_call\|registerService\|IOAccelerator' "$F" | head -40
