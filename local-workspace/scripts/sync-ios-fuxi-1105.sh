#!/bin/bash
# Push this morning's progress and scripts to ios-fuxi. Explicit list, secret scan, normal push.
set -euo pipefail
R=/root/fuxi/ios-fuxi; D=progress/2026-11-05/claude; S=/mnt/e/DSH-Fuxi/dump/wsl
cd "$R"
git pull -q --ff-only origin main
mkdir -p "$D/scripts"
tr -d '\r' < $S/progress-1105-morning.md > "$D/README.md"
tr -d '\r' < /mnt/e/DSH-Fuxi/HANDOFF-GPU-deepseek-4.md > progress/2026-11-04/claude/HANDOFF-GPU-deepseek-4.md
for f in apfs-read.py make-t50-privlog.sh make-t50-plugin.sh make-t50-auto.sh make-t50-gpu-120.sh run-auto-test.ps1 fuxi-buttons-blob.c patch-t32-buttons.py; do tr -d '\r' < $S/$f > "$D/scripts/$f"; done
F=$(git ls-files -mo --exclude-standard)
echo "$F"
if echo "$F" | grep -E '\.(img|bin|macho|ipsw|key|pem)$|data-raw|lscan\.txt|token'; then echo "forbidden file"; exit 1; fi
if echo "$F" | xargs -d '\n' grep -n -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo "secret-like content: not committing"; exit 1; fi
echo "$F" | xargs -d '\n' git add --
git diff --cached --stat | tail -1
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "progress: 11-05 morning, plugin port built, private log images

Nothing tested on the phone yet."
git push -q origin main
git log --oneline -1 | cut -c1-80; git status -sb | head -1
