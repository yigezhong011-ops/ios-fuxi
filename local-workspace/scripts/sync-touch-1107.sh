#!/bin/bash
# Publish the touch-injection milestone and its screenshots.
set -euo pipefail
E=/mnt/e/DSH-Fuxi
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-07
mkdir -p "$R/$DEST/scripts/wsl" "$R/$DEST/shots"
cp "$E/进度-20261107-触摸注入.md" "$R/$DEST/README-touch-injection.md"
for n in touch-cave.c make-t50-touch.sh ctl-shot2.ps1 ctl-attach.ps1 decode-touch3.sh find-touch-symbols.py; do
  tr -d '\r' < "$E/dump/wsl/$n" > "$R/$DEST/scripts/wsl/$n"
done
for i in 1 3 4; do
  src="$E/logs/shot-t50-auto-touch3-231134-$i.png"
  [ -f "$src" ] && cp "$src" "$R/$DEST/shots/lock-home-maps-$i.png"
done
cd "$R"
git add "$DEST"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "敏感内容，不提交"; exit 1
fi
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "touch injection over the USB control channel works on fuxi

A cave over copyio_test registers the screenshot provider and, before each frame, publishes one
gesture through the driver's own touch sink. The first frame of a boot swipes up from the lock
screen; later frames tap rotating points. A five-frame run went lock screen, home screen, then
Maps opening, which is the first end-to-end proof that the phone can be driven without touching
it. Adds the cave, the build script, the capture scripts and three screenshots."
git push -q origin main
git log --oneline -1
