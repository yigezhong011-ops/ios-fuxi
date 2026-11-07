#!/bin/bash
# The auto-return test images, now with readable private arguments. Replaces none of the existing images.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh
bash /tmp/pl.sh /root/fuxi/gpu-new-t50-mine /root/fuxi/t50-priv
bash /tmp/a.sh /root/fuxi/t50-priv 200 t50-auto200p
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-120clock /root/fuxi/t50-priv-120clock
bash /tmp/a.sh /root/fuxi/t50-priv-120clock 300 t50-auto-120clock-p
ls -la /mnt/e/DSH-Fuxi/t50-auto200p.img /mnt/e/DSH-Fuxi/t50-auto-120clock-p.img | cut -c24-100
