#!/bin/bash
# Is there any HEVC encoder behind VideoToolbox on this port?
set -uo pipefail
L=/mnt/e/DSH-Fuxi/logs/carve-coh2/lscan.txt
echo "=== VideoToolbox / 编码器错误码 ==="
for k in 'VideoToolbox' 'kVTVideoEncoderNotFoundErr' '-12906' '12906' 'AppleAVE' 'AVE' 'encoderNotFound' \
         'CMPhoto' 'ImageIOError'; do
  printf '  %-32s %s\n' "$k" "$(grep -ac "$k" "$L" 2>/dev/null || echo 0)"
done
echo
echo "=== 编码器相关具体行（前 10 条）==="
grep -a -m 10 -E 'encoderNotFound|kVTVideoEncoder|-12906|AppleAVE|VideoEncoder' "$L" | cut -c1-210
echo
echo "=== CMPhoto 其他错误（去重前 8 条）==="
grep -a -m 8 -E 'CMPhoto.*(error|err =)' "$L" | cut -c1-210
