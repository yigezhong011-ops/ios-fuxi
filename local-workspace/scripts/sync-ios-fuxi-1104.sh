#!/bin/bash
# Sync the 2026-11-04 notes to ios-fuxi with an explicit file list and a secret scan. Normal push only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; R=/root/fuxi/ios-fuxi; DEST=$R/progress/2026-11-04/claude
cd "$R"
git pull -q --ff-only origin main
mkdir -p "$DEST/scripts/wsl"
tr -d '\r' < $E/dump/wsl/progress-1104.md > "$DEST/README.md"
for n in dscan.c carve-oslog.ps1 pick-oslog-heads.py read-oslog-carve.py make-t50-gpu-apps.sh make-t50-gpu-migrate.sh read-dsc-assert.py read-dsc-caller.py read-dsc-xref.py; do
  tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done
python3 -I - <<'EOF'
p = 'README.md'
t = open(p, encoding='utf-8').read()
line = '- [progress/2026-11-04](progress/2026-11-04/README-gpu-ci.md)'
new = '- [progress/2026-11-04/claude](progress/2026-11-04/claude/README.md)：自带应用装上（数据迁移被跳过是原因）、卡顿原因、壁纸崩溃定位\n'
if 'progress/2026-11-04/claude' not in t:
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
git diff --cached --stat | tail -14
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "progress 2026-11-04: stock apps installed, lag cause, wallpaper crash located

The staged system apps reach the desktop once they are copied into Data and
data migration runs; the seed's LastSystemVersion had skipped it. Lag follows
the per-boot coherence probe. The wallpaper picker crash is the dataStore != nil
assertion; why it is nil, the black wallpaper and white widgets stay open.
Corrects two earlier claims. No images, kernels, IPSW, keys or raw device data."
git push -q origin main
git log --oneline -1
