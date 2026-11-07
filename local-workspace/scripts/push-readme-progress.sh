#!/bin/bash
# Put the current-progress section at the top of ios-fuxi's README (after the title line), once; the rest stays as it is.
set -euo pipefail
R=/root/fuxi/ios-fuxi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
SECTION=$(tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/readme-progress-section.md)
if grep -q '## 当前进度：UniXNU' README.md; then
  python3 - "$SECTION" <<'PY'
import re, sys
t = open('README.md').read()
start = t.index('## 当前进度：UniXNU')
end = t.index('---\n', start) + 4
open('README.md', 'w').write(t[:start] + sys.argv[1].rstrip('\n') + '\n' + t[end:].lstrip('\n'))
PY
else
  python3 - "$SECTION" <<'PY'
import sys
t = open('README.md').read()
first, rest = t.split('\n', 1)
open('README.md', 'w').write(first + '\n\n' + sys.argv[1].rstrip('\n') + '\n\n' + rest.lstrip('\n'))
PY
fi
if grep -n -E 'ghp_|github_pat_|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' README.md; then echo "secret-like content: stop"; exit 1; fi
git diff --stat
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -am \
  "README: current progress of the UniXNU / iPadOS 17 lane

A status table and links to progress/2026-11-01 and progress/2026-11-02 at the
top of the README; the original iOS 16 description below is unchanged."
git push -q origin main
git log --oneline -1
