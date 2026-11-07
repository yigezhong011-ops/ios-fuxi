#!/bin/bash
set -uo pipefail
echo "=== age 可用吗 ==="
which age age-keygen 2>/dev/null || echo "（没有 age）"
echo
echo "=== 私钥在吗 ==="
ls -l /mnt/e/DSH-Fuxi/keys/fuxi-ci-age.key 2>/dev/null || echo "（找不到私钥）"
echo
echo "=== 现成脚本 ==="
for s in addon-set-clients.py addon-clients-exact.py addon-clients-trim.py fat-inplace.py \
         repack-with-vol.py compare-loaders.py make-t36-bl2.sh decode-log.sh; do
  if [ -f "/mnt/e/DSH-Fuxi/dump/wsl/$s" ]; then echo "  有 $s"; else echo "  缺 $s"; fi
done
echo
echo "=== 信任包脚本 ==="
ls -l /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/make-owner-trust-bundle.py 2>/dev/null
echo
echo "=== 当前附加包与信任缓存 ==="
ls -l /root/fuxi/t36-bl2/vol.img 2>/dev/null
