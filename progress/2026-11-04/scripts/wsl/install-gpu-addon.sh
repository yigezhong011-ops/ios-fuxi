#!/bin/bash
# Install a freshly built GPU addon into the daily t36-bl2 volume:
#   decrypt the CI artifact, force the addon to the resident size, replace the owner
#   module's CDHashes in the trust cache in place, write both into the volume, repack.
# Usage: install-gpu-addon.sh <run-id>
set -uo pipefail
RUN=${1:?需要 CI run id}
LOG=/root/fuxi/install-gpu.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) run $RUN ==="

W=/root/fuxi/gpu-new
rm -rf "$W"; mkdir -p "$W"
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)

echo "--- 下载 artifact ---"
ART=$(curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
      "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$RUN/artifacts" \
      | python3 -c 'import json,sys; a=json.load(sys.stdin)["artifacts"]; print(next((x["archive_download_url"] for x in a if "gpu" in x["name"]), ""))')
[ -n "$ART" ] || { echo "没有 gpu artifact"; exit 1; }
curl -fsSL -L -H "Authorization: Bearer $TOKEN" "$ART" -o "$W/art.zip"
unzip -o -q "$W/art.zip" -d "$W/art"
find "$W/art" -type f | head -5

echo "--- 解密 ---"
F=$(find "$W/art" -name '*.age' | head -1)
[ -n "$F" ] || { echo "没有 .age 文件"; exit 1; }
age -d -i /mnt/e/DSH-Fuxi/keys/fuxi-ci-age.key "$F" > "$W/gpu.tar.gz"
tar xzf "$W/gpu.tar.gz" -C "$W"
ls -l "$W/gpuaddon.bin" "$W/cdhashes.txt" 2>/dev/null || { echo "解包内容不对"; ls "$W"; exit 1; }

echo "--- 附加包等长调整 ---"
ORIG=/root/fuxi/t36-bl2/addon-orig.bin
if [ ! -f "$ORIG" ]; then
  mtype -i /root/fuxi/t36-bl2/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > "$ORIG"
  echo "取出原附加包 $(stat -c%s "$ORIG") 字节"
fi
python3 /mnt/e/DSH-Fuxi/dump/wsl/fit-addon.py "$ORIG" "$W/gpuaddon.bin" "$W/addon-fitted.bin" || exit 1
ls -l "$W/addon-fitted.bin"

echo "--- 信任缓存 ---"
mtype -i /root/fuxi/t36-bl2/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > "$W/trust-orig.bin"
python3 /mnt/e/DSH-Fuxi/dump/wsl/patch-trustcache.py "$W/trust-orig.bin" "$W/cdhashes.txt" "$W/trust-new.bin" || exit 1
ls -l "$W/trust-orig.bin" "$W/trust-new.bin"

echo "--- 写入卷（原地） ---"
cp /root/fuxi/t36-bl2/vol.img "$W/vol.img"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon "$W/addon-fitted.bin"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.trustcache "$W/trust-new.bin"

echo "--- 重新打包 ---"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py /mnt/e/DSH-Fuxi/t36-bl2.img "$W/vol.img" /mnt/e/DSH-Fuxi/t36-gpu-fix.img
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py /mnt/e/DSH-Fuxi/t36-gpu-fix.img
echo "=== $(date) 结束 ==="
