#!/bin/bash
# Sync today's progress (docs + scripts, no images / kernels / keys / device seed) into
# yigezhong011-ops/ios-fuxi under progress/2026-11-01/. Existing content of the repository is not touched.
# Usage: sync-ios-fuxi.sh [--push]   (without --push: stage, scan and show what would be committed)
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-01
E=/mnt/e/DSH-Fuxi
if [ ! -d "$R/.git" ]; then
  git clone -q "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/ios-fuxi.git" "$R"
fi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
mkdir -p "$DEST/scripts/wsl" "$DEST/scripts/win"
cp "$E/STATUS-2026-11-01-touch.md" "$E/REPORT-t32-perf.md" "$E/REQUEST-ljhhkx529-touch.md" "$DEST/"
cp "$E/progress-README.md" "$DEST/README.md"
# The scripts written for this progress, by name: other files in dump/wsl belong to earlier work or other sessions
# (some carry the device seed).
WSL_FILES="adt-compare-nodes.sh adt-edit.py adt-node-props.py adt-tree.py adt-uart-nodes.py bootimg-info.py build-fts3.sh
build-reset-after.sh build-stub-reset.sh compare-touch-exports.sh dispatch-fts-touch-old.py dump-hid-desc.py extract-boot-adt.py
find-button-args.sh find-button-source.sh find-button-support.sh find-e3-writer.sh find-fuxi-keys.sh find-hid-allocators.sh
fix-fts-touch-link.sh fix-old-tree-upload.sh FuxiTouchCompat.c fuxi-buttons-blob.c gh-get-file.py gh-repo-overview.py gh-tree.py
inspect-scratch-data.sh inspect-third-party.sh kstr.py list-arm-init-calls.sh list-kernel-args.sh make-arg-variant.sh
make-fts-touch-branch.sh make-t31-aks1.sh make-t31-safe.sh make-t32-buttons.sh make-t32-buttons-diag.sh make-t32-diag.sh
make-t32-fastdiag.sh make-t32-max.sh make-t32-pause.sh make-t32-perf.sh make-t32-perfdiag.sh make-t32-phone.sh
oddly-image-ci.py pack-fts-own.sh pack-payload.sh panel-outline.sh patch-panic-fts4.sh patch-serial-init-ret0.py
patch-t32-buttons.py prepare-oddly-image-ci.sh push-old-tree-branch.sh show-hid-flags.sh show-hid-probe-body.sh show-hid-start.sh
show-identity.sh show-loader-head.sh show-probe-cave.sh wait-oddly-image-ci.py"
for n in $WSL_FILES; do tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"; done
for f in "$E"/dump/win/*.py; do tr -d '\r' < "$f" > "$DEST/scripts/win/$(basename "$f")"; done

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
    "progress 2026-11-01: touch, desktop, frame rate, buttons

Docs and scripts of 2026-11-01 under progress/2026-11-01: FTS touch proven in our
own kernel, the third-party t32 image on the desktop with touch, frame-rate
arguments (sheng-fb-gpu=1, sheng-gpu-pause-us=100), and the PMIC button poller
injected into t32 (reading works; delivery to iOS still open). No images,
kernels, keys or device seed."
  git push -q origin main
  git log --oneline -1
fi
