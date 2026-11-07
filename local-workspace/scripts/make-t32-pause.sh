#!/bin/bash
# t32-pause: t32-fast (sheng-fb-gpu=1, no diagnostic page) plus sheng-gpu-pause-us=100: the GPU fence waiter sleeps
# 100 us between polls instead of the default 1000 us (ljhhkx529 BUILD-PROGRESS: "fence waiter 的睡眠时长，默认 1000us；
# fuxi 之前硬编码 100us"). GPU and CPU are mostly idle in t32-perfdiag, so frame pacing is what is left to shorten.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-pause \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-pause-us=100 \
  | grep -o 'sheng-gpu-pause-us=[0-9]*\|sheng-fb-gpu=[0-9]\|t32-pause_OK'
