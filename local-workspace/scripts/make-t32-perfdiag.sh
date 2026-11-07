#!/bin/bash
# t32-perfdiag: t32-fastdiag (sheng-fb-gpu=1, diagnostic page on) plus the GPU held at its top OPP, without direct scanout.
# t32-diag showed sheng-dpu-scanout=2 drops this kernel to CPU copies (gpu offers=0); t32-fastdiag reached ~23 swaps/s while
# scrolling with GPU copies. Compare the SWAP count per second against t32-fastdiag.
set -euo pipefail
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/make-arg-variant.sh > /root/fuxi/make-arg-variant.sh
bash /root/fuxi/make-arg-variant.sh /root/fuxi/t32/vol.img t32-perfdiag sheng-fb-gpu=1 add:sheng-gpu-perf=8 add:sheng-gpu-dcvs-min=8 \
  | grep -o 'sheng-gpu-perf=[0-9]\|sheng-gpu-dcvs-min=[0-9]\|sheng-dpu-scanout=[0-9]\|t32-perfdiag_OK'
