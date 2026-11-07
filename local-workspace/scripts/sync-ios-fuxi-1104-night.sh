#!/bin/bash
# Sync tonight's notes to ios-fuxi with an explicit file list and a secret scan. Normal push only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; R=/root/fuxi/ios-fuxi; DEST=$R/progress/2026-11-04/claude
cd "$R"
git pull -q --ff-only origin main
mkdir -p "$DEST/scripts/wsl"
tr -d '\r' < $E/dump/wsl/progress-1104-night.md > "$DEST/README-night.md"
tr -d '\r' < $E/HANDOFF-GPU-deepseek-4.md > "$DEST/HANDOFF-GPU-deepseek-4.md"
for n in lscan.c read-lscan.py read-lscan2.py read-lscan3.py read-wall1.py read-wall2.py read-dsc-build.py make-t50-gpu-wall.sh pull-wall.ps1 pull-data.ps1 read-data-raw.sh; do
  tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done
python3 -I - <<'EOF'
p = 'README.md'
t = open(p, encoding='utf-8').read()
line = '- [progress/2026-11-04/claude](progress/2026-11-04/claude/README.md)'
new = '- [progress/2026-11-04/claude/README-night.md](progress/2026-11-04/claude/README-night.md)：壁纸和小组件排查，黑壁纸未修好；系统日志可从 Data 直接取\n'
if 'README-night.md' not in t:
    assert line in t
    t = t.replace(line, new + line, 1)
    open(p, 'w', encoding='utf-8', newline='').write(t)
EOF
echo "== secret scan"
if grep -rn -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' "$DEST" README.md; then
  echo "secret-like content found: not committing"; exit 1
fi
echo clean
git add "$DEST" README.md
git diff --cached --stat | tail -18
git diff --cached --name-only | grep -E '\.(img|bin|macho|ipsw|dmg)$|data-raw\.img|data-list\.txt|lscan\.txt' && { echo "binary or raw file staged: not committing"; exit 1; } || true
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "progress 2026-11-04 night: wallpaper still black, system log readable from Data

A phone wallpaper catalog through the overlay mount left the wallpaper black, and
whether the mount took effect is unverified. The unified log can now be read
from raw Data, which shows PosterBoard's data store error about once per launch
and HEVC encode failures around widgets; neither cause is proven. Adds the
handoff to DeepSeek. No images, kernels, IPSW, keys or raw device data."
git push -q origin main
git log --oneline -1
git status -sb | head -2
