#!/bin/bash
# Sync 2026-11-03 progress (docs + scripts + CI workflow, no images / kernels / IPSW / keys / device seed) into
# yigezhong011-ops/ios-fuxi under progress/2026-11-03/. Existing content of the repository is not touched.
# Usage: sync-ios-fuxi-1103.sh [--push]   (without --push: stage, scan and show what would be committed)
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-03/claude   # DeepSeek already owns progress/2026-11-03/ (README, firmware-usb-power, scripts)
E=/mnt/e/DSH-Fuxi
if [ ! -d "$R/.git" ]; then
  git clone -q "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/ios-fuxi.git" "$R"
fi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
rm -rf "$DEST"; mkdir -p "$DEST/scripts/wsl" "$DEST/share-brightness" "$DEST/share-for-author" "$DEST/ci"
cp "$E/progress-2026-11-03-README.md" "$DEST/README.md"
for f in LOG-FINDINGS-2026-11-03.md HANDOFF-GPU-deepseek-2.md HANDOFF-USB-deepseek.md; do cp "$E/$f" "$DEST/$f"; done
cp "$E"/share-brightness/README-*.md "$DEST/share-brightness/"
cp "$E"/share-for-author/README-*.md "$DEST/share-for-author/"
tr -d '\r' < "$E/ci/fuxi-gpu.yml" > "$DEST/ci/fuxi-gpu.yml"
WSL_FILES="fuxi-buttons-blob.c patch-t32-buttons.py patch-canvas.py make-t50-mine.sh make-t36-bl.sh make-t36-bl2.sh make-t36-setup.sh
make-t36-usb.sh make-t36-usbdiag.sh make-t36-canvas.sh make-t36-cc.sh make-t32-iphone14.sh make-t32-bl-fresh.sh build-clean-gpu5.sh
build-gpu67.sh repack-with-vol.py fat-inplace.py make-arg-variant.sh build-userdata.sh push-userdata-chunks.sh verify-userdata.sh
verify-chunks.sh simg-ranges.py simg-first-block.py make-twrp-boot.py check-recovery-img.sh decode-log.sh log-summary.sh
log-root-errors.sh log-usb.sh usbdiag-rows.sh grep-log.sh compare-swap.sh inspect-data-store.sh inspect-img.sh inspect-t36.sh
compare-loaders.py diff-bootimg-payload.py diff-bootimg-vs-vol.py diff-kernels.py find-caves.py blob-sizes.sh probe-t36-bl.py
find-dim-stores.sh legacy-display-args.sh disasm-qud-init.sh disasm-qud-exit.sh disasm-qud-status.sh adt-find-uuid.py
dump-t36-adt.sh push-ci-workflow.sh dispatch-ci-ref.sh ci-run-status.sh ci-run-log.sh ci-wait.sh ci-fail-context.sh ci-first-error.sh
ci-artifact-log.sh video-frames.sh other-fuxi-records.sh"
for n in $WSL_FILES; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n" || echo "missing $n"
done

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo "clean"
git add "$DEST"
git status --short | head -100
echo "files: $(git diff --cached --name-only | wc -l)"
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-03: iPhone 14 Pro layout, USB debug console, boot logs

Daily image t50-mine: the author's t50 kernel (USB debug serial, DSI
brightness) with our PMIC buttons; Dynamic Island, buttons, brightness and
COM3 kernel log work. Rebuilt the iPadOS 17.7.11 userdata, fresh-Data boot
needs sheng-setup=0, logs read through TWRP. Root causes recorded for the
red fallback status bar (360x800 pt canvas), USB (init off the boot CPU)
and blank widgets (plugin without bridge patch 0020).
No images, kernels, IPSW, keys or device seed."
  git push -q origin main
  git log --oneline -1
fi
