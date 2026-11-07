#!/bin/bash
# Build the plugin test image from a CI run, with private log arguments and auto return. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
for f in make-t50-plugin make-t50-privlog make-t50-auto; do tr -d '\r' < $S/$f.sh > /tmp/$f.sh; done
bash /tmp/make-t50-plugin.sh 41941266963 /root/fuxi/gpu-plugin-1105
bash /tmp/make-t50-privlog.sh /root/fuxi/gpu-plugin-1105 /root/fuxi/t50-priv-plugin
bash /tmp/make-t50-auto.sh /root/fuxi/t50-priv-plugin 300 t50-auto-plugin-p
ls -la /mnt/e/DSH-Fuxi/t50-auto-plugin-p.img | cut -c24-100
sha256sum /mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img | cut -c1-16
grep -a -c 'SharedShaderCache' /root/fuxi/ci-41941266963.log || true
grep -n -E 'added \[|Applying|0025' /root/fuxi/ci-41941266963.log | cut -c30-140 | head -5
