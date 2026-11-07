#!/bin/bash
# Publish the evening findings (EPSS, frame pacing, wallpaper layer) to ios-fuxi.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-05
E=/mnt/e/DSH-Fuxi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main || true
mkdir -p "$DEST/scripts/wsl"
cp "$E/progress-1105-evening.md" "$DEST/README-evening.md"
for n in read-coh-epss.sh read-scanout.sh grep-logwindow.sh check-wallnew.sh grep-datastore.sh \
         grep-wallpaper-layer.sh check-wall-visible.sh who-writes-heic.sh grep-cmphoto.sh \
         probe-data.py data-context.py list-cleanup.py cleanup-move.sh cleanup-pass2.sh \
         delete-confirmed.sh; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done

echo "== 敏感信息扫描 =="
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "命中敏感内容，不提交"; exit 1
fi
echo clean
git add "$DEST"
git status --short | head -20
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-05 (evening): EPSS is static max, the 20 fps is not CPU, the wallpaper layer is hidden

The EPSS probe shows all three frequency domains enabled at 2016/2707/2957 MHz with identical
readings across two rounds, so the CPU is pinned rather than voter-starved. Frame pacing on a
coherence-on boot is still a 49 ms median gap (81% in 40-60 ms) while the panel reports 120 Hz,
so neither CPU frequency nor coherence is the lever. The CoverSheet wallpaper component appears
153 times and is always hidden with alpha 0 while the widget components are visible, which is
why the wallpaper is black; the HEIC write failures are widget snapshots (ChronoServices), not
the wallpaper."
  git push -q origin main
  git log --oneline -1
fi
