#!/bin/bash
# Sync the evening progress into yigezhong011-ops/ios-fuxi under progress/2026-11-02/.
# Docs and scripts only: no images, kernels, keys or device seed.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-02
E=/mnt/e/DSH-Fuxi
if [ ! -d "$R/.git" ]; then
  git clone -q "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/ios-fuxi.git" "$R"
fi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
mkdir -p "$DEST/scripts/wsl"

cp "$E/progress-2026-11-02-evening.md" "$DEST/README-evening.md"
cp "$E/REQUEST-ljhhkx529-gpu-2026-11-02.md" "$DEST/REQUEST-ljhhkx529-gpu.md"

FILES="addon-set-clients.py make-t32-gpu4.sh verify-gpu4.py verify-gpu4-kernel.py
check-vulkan-usage.sh make-wallpaper-overlay.py wallpaper-workflow.yml debug-addon-size.py"
for n in $FILES; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done
# make-wallpaper-overlay.py lives with the reference material
[ -f "$E/read/wallpaper/make-wallpaper-overlay.py" ] && \
  tr -d '\r' < "$E/read/wallpaper/make-wallpaper-overlay.py" > "$DEST/scripts/wsl/make-wallpaper-overlay.py"

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo "clean"
git add "$DEST"
git status --short | head -40
echo "files: $(git diff --cached --name-only | wc -l)"
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-02 (evening): GPU client list built, wallpaper overlay generated

Fixed the addon same-size rewrite (it rebuilt the whole 12 MB container inside the
padding search and never finished; now analytic, 0.13 s) and built t32-gpu4 with
SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences, verified end to
end (kernel sha, addon client list, boot args, 6 changed 64 KiB ranges). Generated
the iPadOS 17 default wallpaper's PNG/JPEG overlay on a macOS runner. Recorded why
it cannot go into the addon without rebuilding the payload, and the request to
ljhhkx529 with the upstream GPU pins. No images, kernels, keys or device seed."
  git push -q origin main
  git log --oneline -1
fi
