#!/bin/bash
# Which boot args and messages does the t50 kernel have around fences and GPU waits?
set -uo pipefail
K=/root/fuxi/t50-mine/kernel.macho
echo "=== sheng-gpu-* 参数名 ==="
strings -a "$K" | grep -E '^sheng-gpu-[a-z0-9-]+$' | sort -u
echo
echo "=== 和 fence / spin / sleep 有关的字符串 ==="
strings -a "$K" | grep -iE 'fence.*(spin|sleep|timeout|wait)|spin.*fence|gpu-fence' | sort -u | head -12 | cut -c1-140
echo
echo "=== 参数名里含 fence/spin/wait 的 ==="
strings -a "$K" | grep -E '^[a-z][a-z0-9-]*(fence|spin|wait)[a-z0-9-]*$' | sort -u | head -12
