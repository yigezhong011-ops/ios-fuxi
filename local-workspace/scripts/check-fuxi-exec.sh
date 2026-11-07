#!/bin/bash
set -uo pipefail
echo "=== fuxi-exec 是什么 ==="
ls /root/ios-fuxi/xnu/fuxi-exec/ 2>/dev/null
echo
head -30 /root/ios-fuxi/xnu/fuxi-exec/*.c 2>/dev/null | head -40
echo
echo "=== 是否有注入相关的 boot-arg ==="
grep -rn -i 'inject\|dylib\|task_for_pid' /root/ios-fuxi/xnu/fuxi-exec/*.c 2>/dev/null | head -10
