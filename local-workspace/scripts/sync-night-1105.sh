#!/bin/bash
# Publish the night progress (correction + fence/scanout + poster reaping).
set -euo pipefail
E=/mnt/e/DSH-Fuxi
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-05
mkdir -p "$R/$DEST/scripts/wsl"
cp "$E/progress-1105-night.md" "$R/$DEST/README-night.md"
for n in make-t50-argvar2.sh fps-per-run.py list-driver-args.sh find-pe-args.sh \
         check-poster-store.sh count-language.sh context-datastore.sh; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$R/$DEST/scripts/wsl/$n"
done
cd "$R"
git add "$DEST"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "敏感内容，不提交"; exit 1
fi
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "progress 2026-11-05 (night): correction, the fence/scanout waits, and the poster reaping

The sheng-gpu-mailbox and sheng-gpu-wc boot arguments are not parsed by the driver (mailbox is
a thread name in AdrenoPublish.cpp), so the earlier 20 to 65 fps comparison was run-to-run
variance, not a fix. What is stable across boots is the fence wait timeout rate (69-74%), a
5.7 s total wait, and 122 scanout waits of 500 ms each. The wallpaper evidence is that
PosterBoard reaps its store for a language change on every boot, fails to recreate it, and the
CoverSheet wallpaper component stays hidden with alpha 0; the HEIC write failures belong to
ChronoServices widget snapshots."
git push -q origin main
git log --oneline -1
