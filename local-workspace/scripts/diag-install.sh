#!/bin/bash
set -uo pipefail
echo "=== 进程 ==="
ps -eo pid,ppid,etime,args --no-headers | grep -E '[i]nstall-gpu|[a]ge -d|[c]url -|[u]nzip|[d]eepseek-gpu' | cut -c1-130
echo
echo "=== 装包日志 ==="
for f in /root/fuxi/install-gpu-*.log; do
  [ -f "$f" ] || continue
  echo "--- $f ---"
  tail -12 "$f"
done
echo
echo "=== gpu-new 目录 ==="
ls -la /root/fuxi/gpu-new 2>/dev/null | head -12
