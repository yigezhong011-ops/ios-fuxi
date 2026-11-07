#!/bin/bash
set -uo pipefail
for r in https://github.com/theos/sdks.git https://github.com/theos/toolchain-linux-iphone.git https://github.com/theos/toolchain.git; do
  printf '%-52s ' "$r"
  if timeout 30 git ls-remote --heads "$r" >/dev/null 2>&1; then echo OK; else echo FAIL; fi
done
echo '--- 本地 ---'
ls /root/theos/sdks 2>/dev/null | head -5
echo "toolchain/linux: $(ls /root/theos/toolchain/linux 2>/dev/null | tr '\n' ' ')"
echo '--- 日志尾部 ---'
tail -4 /root/hakios-build.log 2>/dev/null
