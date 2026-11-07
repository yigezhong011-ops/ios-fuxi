#!/bin/bash
# Sync the late-night GPU findings into progress/2026-11-02/.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-02
E=/mnt/e/DSH-Fuxi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
mkdir -p "$DEST/scripts/wsl"
cp "$E/progress-2026-11-02-late.md" "$DEST/README-late.md"
cp "$E/REQUEST-ljhhkx529-gpu-2026-11-02.md" "$DEST/REQUEST-ljhhkx529-gpu.md"
for n in make-t32-addon-variant.sh addon-clients-exact.py addon-clients-trim.py verify-gpu5.py grep-gpu-args.py \
         fetch-houji-windows.py show-houji-clients.py check-upstream-clients.py; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo clean
git add "$DEST"
git status --short | head -25
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-02 (late): WidgetRenderer_Default turns white widgets black

Client-list bisect on the phone with only the addon changed: Preferences does nothing,
WidgetRenderer_Default takes the widgets from white to black (device granted, no window),
four clients crash at the Mi logo. The kernel's kClientWindows gives the render server plus
two client windows and no boot argument changes that. Found the fix in lonzzi/UniXNU-houji
(SM8550): a four-window kClientWindows table, and a five-slot revision in its slot checks.
Adds the exact and trim-based client-list tools and the window findings."
  git push -q origin main
  git log --oneline -1
fi
