#!/bin/bash
# What do the mailbox / wc / adaptive-spin knobs look like in the t50 kernel?
set -uo pipefail
K=/root/fuxi/t50-mine/kernel.macho
echo "=== mailbox 相关 ==="
strings -a "$K" | grep -i 'mailbox' | sort -u | head -10 | cut -c1-140
echo
echo "=== wc / write-combine 相关 ==="
strings -a "$K" | grep -iE 'write.?comb|gpu-wc' | sort -u | head -8 | cut -c1-140
echo
echo "=== adaptive-spin 上下文 ==="
strings -a "$K" | grep -i -B2 -A2 'adaptive-spin' | head -10 | cut -c1-140
echo
echo "=== IOFence 超时消息 ==="
strings -a "$K" | grep -i 'IOFence' | sort -u | head -10 | cut -c1-160
