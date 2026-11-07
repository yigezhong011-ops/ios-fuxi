#!/bin/bash
# Clone the UniXNU build inputs so tomorrow starts at the build, not the download.
set -uo pipefail
BASE=/mnt/e/DSH-Fuxi/unixnu-build
mkdir -p "$BASE"
cd "$BASE"

clone() {
  local url=$1 dir=$2 branch=${3:-}
  if [ -d "$dir/.git" ]; then
    echo "== $dir 已存在，跳过"
    return
  fi
  echo "== 克隆 $dir"
  if [ -n "$branch" ]; then
    git clone --depth 1 --branch "$branch" "$url" "$dir" 2>&1 | tail -2
  else
    git clone --depth 1 "$url" "$dir" 2>&1 | tail -2
  fi
}

clone https://github.com/UniXNU/UniXNU.git unixnu main
clone https://github.com/ljhhkx529/unixnu-fuxi.git fuxi old
clone https://github.com/ljhhkx529/uefi-fuxi.git uefi-fuxi old

echo
echo "=== 结果 ==="
for d in unixnu fuxi uefi-fuxi; do
  [ -d "$d" ] && printf '%-12s %s\n' "$d" "$(du -sh "$d" 2>/dev/null | cut -f1)"
done
echo
echo "=== unixnu 目录 ==="
ls unixnu 2>/dev/null | head -15
echo
echo "=== unixnu 驱动是否可运行 ==="
[ -f unixnu/unixnu ] && echo "有 ./unixnu" || echo "没有 ./unixnu（可能需要构建）"
ls unixnu/*.py 2>/dev/null | head -5
