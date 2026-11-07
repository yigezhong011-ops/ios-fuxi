#!/bin/bash
set -uo pipefail
THEIRS=/mnt/e/DSH-Fuxi/dump/ABI-unixnu.h
cp "$THEIRS" /tmp/ABI.h
cat > /tmp/abi2.c <<'EOF'
#include <stdio.h>
#include <stdint.h>
#include "ABI.h"
int main(void) {
    printf("Params       %zu\n", sizeof(struct NativeAdrenoAbiParams));
    printf("BoAlloc      %zu\n", sizeof(struct NativeAdrenoAbiBoAlloc));
    printf("BoAllocReply %zu\n", sizeof(struct NativeAdrenoAbiBoAllocReply));
    printf("BoMap        %zu\n", sizeof(struct NativeAdrenoAbiBoMap));
    printf("BoMapReply   %zu\n", sizeof(struct NativeAdrenoAbiBoMapReply));
    printf("Submit       %zu\n", sizeof(struct NativeAdrenoAbiSubmit));
    printf("WaitFence    %zu\n", sizeof(struct NativeAdrenoAbiWaitFence));
    printf("BoImport     %zu\n", sizeof(struct NativeAdrenoAbiBoImport));
    printf("SubmitBuffer %zu\n", sizeof(struct NativeAdrenoAbiSubmitBuffer));
    printf("MaxBuffers   %d\n", NativeAdrenoAbiMaxBuffers);
    return 0;
}
EOF
cd /tmp && clang -o abi2 abi2.c 2>&1 | head -8 && ./abi2
echo "=== 他们的 submit 结构定义 ==="
sed -n '70,110p' "$THEIRS"
