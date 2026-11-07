#!/bin/bash
# Push this afternoon's progress and scripts to ios-fuxi. Explicit list, secret scan, normal push.
set -euo pipefail
R=/root/fuxi/ios-fuxi; D=progress/2026-11-05/claude; S=/mnt/e/DSH-Fuxi/dump/wsl
cd "$R"
git pull -q --ff-only origin main
mkdir -p "$D/scripts"
tr -d '\r' < $S/progress-1105-afternoon.md > "$D/README-afternoon.md"
for f in make-t50-addarg.sh make-t50-cpu-test2.sh make-t50-load-test.sh read-cadence.py read-auto200p.py read-auto200p2.py read-auto200p3.py fuxi-buttons-blob.c patch-t32-buttons.py; do tr -d '\r' < $S/$f > "$D/scripts/$f"; done
F=$(git ls-files -mo --exclude-standard)
echo "$F"
if echo "$F" | grep -E '\.(img|bin|macho|ipsw|key|pem|plist)$|data-raw|lscan\.txt|token'; then echo "forbidden file"; exit 1; fi
if echo "$F" | xargs -d '\n' grep -n -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo "secret-like content: not committing"; exit 1; fi
echo "$F" | xargs -d '\n' git add --
git diff --cached --stat | tail -1
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "progress: 11-05 afternoon, autoreset works, panel 120, widgets normal

Frame rate in use is still about 30 fps; wallpaper still black."
git push -q origin main
git log --oneline -1 | cut -c1-80; git status -sb | head -1