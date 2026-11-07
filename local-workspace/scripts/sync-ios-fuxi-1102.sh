#!/bin/bash
# Sync 2026-11-02 progress (docs + scripts, no images / kernels / keys / device seed) into
# yigezhong011-ops/ios-fuxi under progress/2026-11-02/. Existing content of the repository is not touched.
# Usage: sync-ios-fuxi-1102.sh [--push]   (without --push: stage, scan and show what would be committed)
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
cp "$E/progress-2026-11-02-README.md" "$DEST/README.md"
# The scripts of this day's work, by name: other files in dump/wsl belong to earlier work or other sessions.
WSL_FILES="fuxi-buttons-blob.c patch-t32-buttons.py make-t32-buttons.sh make-t32-buttons-diag.sh make-t32-buttons-bl.sh
make-t32-bl-diag.sh make-arg-variant.sh pack-payload.sh disasm-sym.py fuxi-panel-bl.sh fuxi-i2c-a84000.sh find-hid-counters.sh
gh-commits.py gh-commit-diff.py gh-builds.py gh-grep-tree.py gh-code-search.py device-area.py device-input-area.py
get-ljh-buttons.sh get-backlight-src.sh get-oled-backlight-refs.sh find-dsi-brightness.sh ci-runs.py
make-t32-bl.sh make-t32-gpu-clients.sh make-t32-iphone.sh make-t32-nopersist2.sh make-t32-nopersist3.sh addon-set-clients.py
list-gpu-addon.py bootimg-sizes.py read-kva.py show-cave-sections.sh measure-payload-room.sh diff-blob-kick.sh show-t32-identity.sh
get-wallpaper-refs.sh find-wallpaper.sh find-wallpaper-overlay.sh find-ipsw-wallpaper.sh find-pong-iphone.sh get-pong-iphone.sh"
for n in $WSL_FILES; do tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"; done

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo "clean"
git add "$DEST"
git status --short | head -80
echo "files: $(git diff --cached --name-only | wc -l)"
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-02 (afternoon): DSI brightness working

Panel brightness works on the phone: t32's ShengBacklight with its transport
moved to DCS 0x51 over DSI0 (359 requests, 359 writes, no failure). Also the
packed Data seed in the payload FAT's free clusters (never zero or reallocate
them), GPU client-list tooling, and the wallpaper / iPhone-layout research.
No images, kernels, keys or device seed."
  git push -q origin main
  git log --oneline -1
fi
