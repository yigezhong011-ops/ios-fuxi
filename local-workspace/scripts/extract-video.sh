#!/bin/bash
set -euo pipefail
V="/mnt/e/xwechat_files/wid_placeholder.mp4"
V=$(ls /mnt/e/xwechat_files/*/msg/video/2026-10/08f5e190d8d57056a547d9058c4e52e2.mp4 2>/dev/null | head -1)
echo "视频: $V"
mkdir -p /root/fuxi/frames
ffmpeg -hide_banner -loglevel error -i "$V" -vf "fps=1/2,scale=540:-1" -frames:v 4 /root/fuxi/frames/f%02d.png
ls -l /root/fuxi/frames/
cp /root/fuxi/frames/f01.png /mnt/e/DSH-Fuxi/vid1.png
cp /root/fuxi/frames/f02.png /mnt/e/DSH-Fuxi/vid2.png
cp /root/fuxi/frames/f03.png /mnt/e/DSH-Fuxi/vid3.png
cp /root/fuxi/frames/f04.png /mnt/e/DSH-Fuxi/vid4.png 2>/dev/null || true
echo FRAMES_OK
