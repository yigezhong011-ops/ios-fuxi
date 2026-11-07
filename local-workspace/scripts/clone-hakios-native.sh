#!/bin/bash
# Clone HakiOS into the WSL filesystem (188 MB over drvfs is too slow).
set -uo pipefail
cd /root
for repo in hakios-xnu-kernel hakios-sm7325 hakios-metal; do
  if [ -d "/root/$repo/.git" ]; then
    echo "$repo 已存在"
    continue
  fi
  echo "=== 克隆 $repo ==="
  git clone -q --depth 1 "https://github.com/oosexgang/$repo.git" "/root/$repo" && echo "  完成 $(du -sh /root/$repo | cut -f1)"
done
echo "=== 结果 ==="
du -sh /root/hakios-* 2>/dev/null
ls /root/hakios-xnu-kernel 2>/dev/null | head -20
