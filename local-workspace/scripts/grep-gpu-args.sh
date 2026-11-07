#!/bin/bash
set -uo pipefail
K=/root/fuxi/t32/kernel.macho
echo "=== 内核里的 sheng-gpu-* 启动参数 ==="
strings -a "$K" 2>/dev/null | grep -E '^sheng-gpu-[a-z0-9-]+$' | sort -u | head -30
echo
echo "=== 采样 / 窗口 / 客户端 相关 ==="
strings -a "$K" 2>/dev/null | grep -iE 'single.?sample|kClientWindow|client.?window|sample.?count|msaa' | sort -u | head -20 | cut -c1-130
echo
echo "=== sheng-metal* / addon 参数 ==="
strings -a "$K" 2>/dev/null | grep -E '^sheng-(metal|addon)[a-z0-9-]*$' | sort -u | head -15
