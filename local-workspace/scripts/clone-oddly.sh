#!/bin/bash
# Clone the OddlyLabs fuxi touch stack (UniXNU fork, device repo, UEFI fork).
set -uo pipefail
cd /root
for spec in "OddlyLabs/UniXNU:fuxi:uni-odd" "OddlyLabs/unixnu-fuxi:main:dev-odd" "OddlyLabs/uefi-fuxi:fuxi:uefi-odd"; do
  IFS=':' read -r repo branch dir <<< "$spec"
  if [ -d "/root/$dir/.git" ]; then
    echo "$dir 已存在"
    continue
  fi
  echo "=== $repo ($branch) -> $dir ==="
  git clone -q --depth 1 --branch "$branch" --recurse-submodules \
    "https://github.com/$repo.git" "/root/$dir" 2>&1 | tail -3
  [ -d "/root/$dir" ] && echo "  完成 $(du -sh /root/$dir | cut -f1)"
done
echo
echo "=== 结果 ==="
du -sh /root/uni-odd /root/dev-odd /root/uefi-odd 2>/dev/null
echo "=== 设备仓库里的触控驱动 ==="
ls /root/dev-odd/drivers 2>/dev/null
ls /root/dev-odd/drivers/FuxiFtsTouch 2>/dev/null | head -8
