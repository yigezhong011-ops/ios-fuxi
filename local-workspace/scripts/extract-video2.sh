#!/bin/bash
set -euo pipefail
V=/mnt/e/xwechat_files/wxid_ufcunrrmn9p22_4361/msg/video/2026-10/27e20285c082afe73d0dbc075e78e0e6.mp4
[ -f "$V" ] || { echo "missing $V"; exit 1; }
mkdir -p /root/fuxi/frames2
rm -f /root/fuxi/frames2/*.png
ffmpeg -hide_banner -loglevel error -i "$V" -vf "fps=1/1.5,scale=480:-1" -frames:v 6 /root/fuxi/frames2/f%02d.png
ls -l /root/fuxi/frames2/
for i in 1 2 3 4 5 6; do
  [ -f "/root/fuxi/frames2/f0$i.png" ] && cp "/root/fuxi/frames2/f0$i.png" "/mnt/e/DSH-Fuxi/m$i.png"
done
echo FRAMES_OK
