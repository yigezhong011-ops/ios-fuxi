#!/bin/bash
set -uo pipefail
OURS=/root/ios-fuxi/xnu/fuxi-adreno/NativeAdrenoABI.h
THEIRS=/mnt/e/DSH-Fuxi/dump/ABI-unixnu.h
echo "=== 结构体大小对比（用 clang 计算）==="
cat > /tmp/abi_sizes.c <<'EOF'
#include <stdio.h>
#include <stdint.h>
#include "ABI.h"
int main(void) {
    printf("Query        %zu\n", sizeof(struct NativeAdrenoAbiParams));
    printf("BoAlloc      %zu\n", sizeof(struct NativeAdrenoAbiBoAlloc));
    printf("BoAllocReply %zu\n", sizeof(struct NativeAdrenoAbiBoAllocReply));
    printf("BoMap        %zu\n", sizeof(struct NativeAdrenoAbiBoMap));
    printf("BoMapReply   %zu\n", sizeof(struct NativeAdrenoAbiBoMapReply));
    printf("Submit       %zu\n", sizeof(struct NativeAdrenoAbiSubmit));
    printf("WaitFence    %zu\n", sizeof(struct NativeAdrenoAbiWaitFence));
    printf("BoImport     %zu\n", sizeof(struct NativeAdrenoAbiBoImport));
    return 0;
}
EOF
for pair in "ours:$OURS" "theirs:$THEIRS"; do
  name=${pair%%:*}; path=${pair#*:}
  [ -f "$path" ] || { echo "$name: 文件不存在 $path"; continue; }
  cp "$path" /tmp/ABI.h
  if clang -o /tmp/abi_sizes /tmp/abi_sizes.c 2>/tmp/abi_err.txt; then
    echo "--- $name ---"
    /tmp/abi_sizes
  else
    echo "--- $name --- 编译失败"; head -5 /tmp/abi_err.txt
  fi
done
