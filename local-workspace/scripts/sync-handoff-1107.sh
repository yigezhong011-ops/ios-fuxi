#!/bin/bash
# Publish the touch-injection handoff (with the counter-print caveat) to ios-fuxi.
set -euo pipefail
E=/mnt/e/DSH-Fuxi
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-07
mkdir -p "$R/$DEST/scripts/wsl"
cp "$E/HANDOFF-触摸注入-claude.md" "$R/$DEST/HANDOFF-touch-injection.md"
for n in touch-cave.c make-t50-touch.sh ctl-shot2.ps1 ctl-attach.ps1 decode-touch3.sh \
         find-print-symbols.py cave-room.sh patch-make-touch.py; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$R/$DEST/scripts/wsl/$n"
done
cd "$R"
git add "$DEST"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "敏感内容，不提交"; exit 1
fi
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "handoff: touch injection works, the serial counter line prints but its values are wrong

The cave over copyio_test now also prints one FUXI120S line per screenshot through the console
printf, so the line reaches COM3. The values it prints are not the driver counters yet: hid,
calls and to are garbage and the gesture phase slot (xs[1]) is overwritten by the driver, so p
is a leftover coordinate. Points at both next steps and at what already works end to end."
git push -q origin main
git log --oneline -1
