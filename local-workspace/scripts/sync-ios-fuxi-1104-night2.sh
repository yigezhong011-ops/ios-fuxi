#!/bin/bash
# Push the corrected handoff to ios-fuxi. Scans the file first; normal push only.
set -euo pipefail
R=/root/fuxi/ios-fuxi; F=progress/2026-11-04/claude/HANDOFF-GPU-deepseek-4.md
cd "$R"
git pull -q --ff-only origin main
tr -d '\r' < /mnt/e/DSH-Fuxi/HANDOFF-GPU-deepseek-4.md > "$F"
if grep -n -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' "$F"; then
  echo "secret-like content found: not committing"; exit 1
fi
git add "$F"
git diff --cached --stat | tail -2
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "handoff: record that 7z cannot list the Data copy

The copy's hash matches the phone, but it may hold only a window of the partition
without the APFS container start, so the next reader needs another method."
git push -q origin main
git log --oneline -1
git status -sb | head -1
