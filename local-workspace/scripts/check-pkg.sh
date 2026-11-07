#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
echo "=== zap 校验（应为 fd107982...）==="
sha256sum "$P"/a740_zap-odm*.mbn "$P"/a740_zap-mbn-12088.bin 2>/dev/null | sed 's#/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/##'
echo
echo "=== 文件头（判 sparse）==="
xxd -l 32 "$P/ios16-root-v11.simg"
echo
echo "=== simg2img 是否可用 ==="
which simg2img || (apt-get install -y android-sdk-libsparse-utils >/dev/null 2>&1 && which simg2img) || echo NO_SIMG2IMG
