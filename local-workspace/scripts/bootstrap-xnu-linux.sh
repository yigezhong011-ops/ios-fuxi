#!/bin/bash
# Build Allenwdk's xnu-linux-toolchain, which provides the host-clang driver for
# XNU's SETUP tools plus the cctools/MIG/iig pieces, so the kernel builds here.
set -uo pipefail
BASE=/mnt/e/DSH-Fuxi/unixnu-build
cd "$BASE"

if [ -d xnu-linux-toolchain/.git ]; then
  echo "== 已存在，更新"
  git -C xnu-linux-toolchain fetch --depth 1 origin main 2>&1 | tail -2
else
  echo "== 克隆工具链"
  git clone --depth 1 https://github.com/Allenwdk/xnu-linux-toolchain.git 2>&1 | tail -2
fi

cd xnu-linux-toolchain
echo "=== 目录 ==="
ls
echo
echo "=== bootstrap.sh 依赖检查 ==="
for t in git cmake make clang python3 flex bison autoconf automake pkg-config; do
  printf '%-12s %s\n' "$t" "$(command -v $t || echo '缺失')"
done
echo
echo "=== 开始 bootstrap（5-8 分钟）==="
timeout 2400 ./bootstrap.sh 2>&1 | tail -30
echo "BOOTSTRAP_EXIT=$?"
ls -d ~/.local/xnu-linux 2>/dev/null && ls ~/.local/xnu-linux/bin 2>/dev/null | head -20
