#!/bin/bash
# Publish the A/B results and the request to the author.
set -euo pipefail
E=/mnt/e/DSH-Fuxi
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-05
mkdir -p "$R/$DEST/scripts/wsl"
cp "$E/REQUEST-ljhhkx529-120fps-wallpaper-2026-11-05.md" "$R/$DEST/REQUEST-120fps-wallpaper.md"
cp "$E/progress-1105-night.md" "$R/$DEST/README-night.md"
for n in fps-phases.py counters-ab.sh dpu-state.sh; do
  tr -d '\r' < "$E/dump/wsl/$n" > "$R/$DEST/scripts/wsl/$n"
done
cd "$R"
git add "$DEST"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "敏感内容，不提交"; exit 1
fi
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "progress 2026-11-05: a controlled A/B pins the stalls on scanout wait timeouts

Same boot, idle then swiping: 17-22 fps with stalls up to 3.2 s, degrading over the run. The
counters show 550 scanout waits of 500 ms each (275 s of a 322 s run) while sent and arms never
leave zero, and the fence waits only add up to 5.7 s. Adds the request to ljhhkx529 with those
numbers and the PosterBoard data-store evidence."
git push -q origin main
git log --oneline -1
