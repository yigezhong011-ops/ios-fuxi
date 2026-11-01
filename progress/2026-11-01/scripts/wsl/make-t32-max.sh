#!/bin/bash
# t32-max: t32-perf plus the two documented speed switches (uni-oddly docs/zh/porting/display.md, devices/sheng.md):
#   sheng-dpu-scanout=2  direct scanout: the display pipes fetch the compositor surface through a stage 1 window of the
#                        display bank instead of a GPU copy to the firmware framebuffer; experimental, any failure falls back
#                        to the GPU copy; the flip waits for the frame's GPU fence.
#   sheng-cpufreq=3      CPU domains fixed at the highest non-turbo level (t32 uses 4, load scaling).
# The panel stays at the 60 Hz the ABL set up; this aims at reaching it, not 120.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-max \
  rm:-v rm:boot-progress=2 rm:armcpu-diagnostics=1 sheng-fb-gpu=1 add:sheng-gpu-perf=8 add:sheng-gpu-dcvs-min=8 \
  add:sheng-dpu-scanout=2 sheng-cpufreq=3 \
  | grep -o 'sheng-gpu-perf=[0-9]*\|sheng-gpu-dcvs-min=[0-9]*\|sheng-dpu-scanout=[0-9]\|sheng-cpufreq=[0-9]\|sheng-fb-gpu=[0-9]\|t32-max_OK'
