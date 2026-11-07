#!/bin/bash
# Push tonight's touch progress to ios-fuxi. Explicit list, secret scan, normal push.
set -euo pipefail
R=/root/fuxi/ios-fuxi; D=progress/2026-11-07/claude; S=/mnt/e/DSH-Fuxi/dump/wsl; L=/mnt/e/DSH-Fuxi/logs
cd "$R"
git pull -q --ff-only origin main
mkdir -p "$D/scripts" "$D/shots"
tr -d '\r' < $S/progress-1107-touch.md > "$D/README.md"
for f in touch-cave2.c patch-t50-tap.py make-t50-tap.sh make-t50-daily-gpu7.sh flash-boot-b-gpu7.ps1 ctl-run.ps1 sweep-home.ps1 read-touch-parser.sh read-touch-hook.sh; do tr -d '\r' < $S/$f > "$D/scripts/$f"; done
cp $L/shot-t50-auto-gpu7tap-001001-desk.png "$D/shots/desk-after-unlock.png"
cp $L/shot-t50-auto-gpu7tap-234109-lock.png "$D/shots/lock-wallpaper.png"
cp $L/shot-attach-094314-settings2.png "$D/shots/settings-wallpaper.png"
F=$(git ls-files -mo --exclude-standard)
echo "$F"
if echo "$F" | grep -E '\.(img|bin|macho|ipsw|key|pem|plist)$|data-raw|lscan\.txt|token'; then echo "forbidden file"; exit 1; fi
if echo "$F" | xargs -d '\n' grep -n -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo "secret-like content: not committing"; exit 1; fi
echo "$F" | xargs -d '\n' git add --
git diff --cached --stat | tail -1
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "touch: taps land after fixing the X scale; the Settings wallpaper page opens on the daily image

x_pt = raw * 360 / 30480, fitted to a grid of taps. The earlier 11790 was wrong.
One run each. The cave's X limit fix is built, not booted and not flashed."
git push -q origin main
git log --oneline -1 | cut -c1-80; git status -sb | head -1
