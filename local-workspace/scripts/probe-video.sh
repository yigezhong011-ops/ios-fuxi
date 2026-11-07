#!/bin/bash
set -uo pipefail
V="/mnt/e/xwechat_files/wxid_ufcunrrmn9p22_4361/msg/video/2026-11/aef28ec4a243fc51273870d14bb70bb0.mp4"
ls -lh "$V" 2>/dev/null || { echo "找不到视频"; exit 1; }
which ffmpeg ffprobe || echo "（没有 ffmpeg）"
echo "--- 信息 ---"
ffprobe -v error -show_entries format=duration,size -show_entries stream=width,height,r_frame_rate -of default=nw=1 "$V" 2>/dev/null | head -12
