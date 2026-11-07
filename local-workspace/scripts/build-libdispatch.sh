#!/bin/bash
# Ubuntu has no libdispatch package; cctools-port's ld64 needs it (and a blocks
# runtime). Build swift-corelibs-libdispatch and install it system-wide.
set -euo pipefail
WORK=/root/fuxi/libdispatch
mkdir -p "$WORK"
cd "$WORK"

if [ ! -d swift-corelibs-libdispatch/.git ]; then
  echo "== 克隆 libdispatch"
  git clone --depth 1 https://github.com/swiftlang/swift-corelibs-libdispatch.git 2>&1 | tail -2
fi

cd swift-corelibs-libdispatch
echo "== 配置"
cmake -B build -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF -DINSTALL_PRIVATE_HEADERS=YES 2>&1 | tail -5
echo "== 编译"
cmake --build build -j"$(nproc)" 2>&1 | tail -8
echo "== 安装"
cmake --install build 2>&1 | tail -5

echo "== 检查"
ldconfig 2>/dev/null || true
ldconfig -p | grep -i dispatch | head -5
ls -l /usr/local/lib/libdispatch* /usr/local/lib/libBlocksRuntime* 2>/dev/null | head -6
