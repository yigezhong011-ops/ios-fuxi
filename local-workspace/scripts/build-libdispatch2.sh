#!/bin/bash
# Rebuild libdispatch with clang (gcc lacks -fmodule-map-file).
set -euo pipefail
cd /root/fuxi/libdispatch/swift-corelibs-libdispatch
rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DBUILD_TESTING=OFF 2>&1 | tail -4
cmake --build build -j"$(nproc)" 2>&1 | tail -6
cmake --install build 2>&1 | tail -4
ldconfig
echo "== 检查"
ldconfig -p | grep -i dispatch | head -4
ldconfig -p | grep -i blocks | head -3
