#!/bin/bash
# Upstream UniXNU: recent commits and the docs on identity (MobileGestalt), wallpaper and the GPU client list (read-only)
out=/mnt/e/DSH-Fuxi/read/upstream
mkdir -p "$out"
python3 /root/fuxi/gh-commits.py UniXNU/UniXNU 25 | cut -c1-170
for f in docs/zh/guide/mobilegestalt.md docs/guide/mobilegestalt.md docs/zh/concepts/userdata.md; do
    python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py UniXNU/UniXNU main "$f" "$out/$(echo "$f" | tr / _)" 2>&1 | tail -1
done
python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-grep-tree.py UniXNU/UniXNU main 'docs/zh/(guide|concepts|porting)/' | awk '{print $3}' | head -60
