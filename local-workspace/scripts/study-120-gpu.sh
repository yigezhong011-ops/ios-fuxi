#!/bin/bash
# Read-only: existing 120 Hz work, t50 kernel provenance, CI setup and plugin sources.
cd /mnt/e/DSH-Fuxi/dump/wsl
echo "== 120 mentions"; grep -n -i -E '120 ?hz|PANEL_120|timing@1' known-good-readme.md readme-progress-section.md make-t32-bl-diag.sh build-clean-gpu5.sh | cut -c1-240 | head -24
echo "== blob"; grep -n -i -E '120|PANEL_|timing|dsc|fps|vsync|refresh' fuxi-buttons-blob.c | cut -c1-170 | head -50
wc -l fuxi-buttons-blob.c
echo "== memory-like docs"; ls -t /mnt/e/DSH-Fuxi/*.md | head -20
echo "== gpu ci"; sed -n 1,60p ci-build.sh | cut -c1-170
echo "== progress gpu ci"; sed -n 1,50p progress-2026-11-04-gpu-ci.md | cut -c1-240
echo "== ci dir"; ls -t ci ci-fail 2>/dev/null | head -30
ls -la /root/fuxi/ci /root/fuxi/src-adrenometal /root/fuxi/uni-oldci 2>/dev/null | cut -c1-90 | head -40
echo "== records"; grep -rIl -i -E '120 ?hz|refresh.?rate|promotion|120 ?fps|ProMotion' /root/build/unixnu/docs /root/build/unixnu/devices /root/build/unixnu/records 2>/dev/null | head -20
grep -rIl -i -E '120 ?hz|timing@1|qcom,mdss-dsi-panel-framerate|refresh.?rate' /root/build/fuxi /root/fuxi/ref-sad-fuxi --exclude-dir=.git 2>/dev/null | head -20
echo "== token"; ls -la /mnt/e/DSH-Fuxi/token2.txt | cut -c1-80; which gh
