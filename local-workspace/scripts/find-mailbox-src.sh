#!/bin/bash
# Find the sheng GPU driver source that reads these boot args.
set -uo pipefail
echo "=== 本地 UniXNU / 驱动树里搜 sheng-gpu-mailbox ==="
for d in /root/fuxi/drv-fork /root/fuxi/uni-fork /root/fuxi/uni-star /root/fuxi/uni-odd \
         /mnt/e/DSH-Fuxi/unixnu-build/unixnu /root/fuxi/fork-device; do
  [ -d "$d" ] || continue
  hits=$(grep -rl --include='*.c' --include='*.cpp' --include='*.h' --include='*.mm' \
         'sheng-gpu-mailbox' "$d" 2>/dev/null | head -3)
  [ -n "$hits" ] && { echo "  $d:"; echo "$hits" | sed 's/^/     /'; }
done
echo
echo "=== 所有出现 mailbox 的驱动源文件（前 10）==="
grep -rl --include='*.cpp' --include='*.c' -E 'gMailbox|MailboxPoller|sheng-gpu-mailbox' \
  /root/fuxi /mnt/e/DSH-Fuxi/unixnu-build 2>/dev/null | head -10
