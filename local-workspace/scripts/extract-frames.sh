#!/bin/bash
set -uo pipefail
V="/mnt/e/xwechat_files/wxid_ufcunrrmn9p22_4361/msg/video/2026-10/d8cb7aadf5c655349f0bdcfa5daa8165.mp4"
OUT=/mnt/e/DSH-Fuxi/frames
rm -rf "$OUT"; mkdir -p "$OUT"
echo "=== 时长 ==="
ffprobe -v error -show_entries format=duration,size -of default=noprint_wrappers=1 "$V"
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V" | cut -d. -f1)
echo "duration=${D}s"
for t in 0 $((D/2)) $((D*3/4)) $((D-1)); do
  [ "$t" -lt 0 ] && t=0
  ffmpeg -v error -y -ss "$t" -i "$V" -frames:v 1 -q:v 2 "$OUT/frame_${t}s.jpg" && echo "frame ${t}s ok"
done
ls -l "$OUT"
echo FRAMES_DONE
