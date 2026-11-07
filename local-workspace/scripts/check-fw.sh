#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/dump/fw-phone
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
echo "=== 我们现在内嵌的固件 ==="
for f in a740_zap.mbn gmu_gen70200.bin a740_sqe.fw; do
  [ -f "$D/$f" ] && printf '%-22s %8s bytes  ' "$f" "$(stat -c%s $D/$f)" && sha256sum "$D/$f" | cut -c1-16
done
echo
echo "=== 包里的 zap ==="
printf '%-30s %8s bytes  ' "a740_zap-odm-fd107982.mbn" "$(stat -c%s $P/a740_zap-odm-fd107982.mbn)"
sha256sum "$P/a740_zap-odm-fd107982.mbn" | cut -c1-16
echo
echo "=== 包里 zap 尺寸对照 README（应为 12088）==="
stat -c%s "$P"/a740_zap-*.mbn "$P"/a740_zap-mbn-12088.bin
