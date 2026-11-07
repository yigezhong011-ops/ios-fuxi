#!/bin/bash
# Check the README links, then commit and push only README.md (no force).
set -euo pipefail
cd /root/fuxi/ios-fuxi
for f in progress/2026-11-04/README-gpu-ci.md progress/2026-11-03/claude/README.md progress/2026-11-03/README.md \
         progress/2026-11-03/firmware-usb-power/README.md progress/2026-11-02/README.md progress/2026-11-01/README.md; do
  [ -f "$f" ] && echo "ok $f" || echo "MISSING $f"
done
echo "changed: $(git status --short)"
[ "${1:-}" = "--push" ] || exit 0
git add README.md
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "README: current status (t50-mine, iPhone 14 Pro layout) and day links up to 2026-11-04"
git push -q origin main
git log --oneline -3
git status --short | wc -l
