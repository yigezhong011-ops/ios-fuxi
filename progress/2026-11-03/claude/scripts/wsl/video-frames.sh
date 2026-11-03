#!/bin/bash
# Grab evenly spaced frames from a video into E:\DSH-Fuxi\frames\<name>\ (ffmpeg in WSL). Usage: video-frames.sh <video> <name> [count]
V=$1; N=${3:-8}; O=/mnt/e/DSH-Fuxi/frames/$2
command -v ffmpeg >/dev/null || apt-get install -y ffmpeg >/dev/null 2>&1
rm -rf "$O"; mkdir -p "$O"
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V")
echo "duration $D s"
for i in $(seq 0 $((N-1))); do
  T=$(python3 -c "print(round($D*($i+0.5)/$N,2))")
  ffmpeg -v error -ss "$T" -i "$V" -frames:v 1 -vf scale=540:-1 "$O/f$i-${T}s.jpg"
done
ls "$O"
