#!/bin/bash
# Publish the GPU CI progress note and the tools that go with it.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
R=/root/fuxi/ios-fuxi
DEST=progress/2026-11-04
E=/mnt/e/DSH-Fuxi
cd "$R"
git fetch -q origin
git checkout -q main
git merge -q --ff-only origin/main
mkdir -p "$DEST/scripts/wsl" "$DEST/ci"
cp "$E/progress-2026-11-04-gpu-ci.md" "$DEST/README-gpu-ci.md"
cp "$E/ci/fuxi-gpu.yml" "$DEST/ci/fuxi-gpu.yml"
for n in install-gpu-addon.sh fit-addon.py patch-trustcache.py add-host-bridge.py \
         stub-quartz-check.py patch-ci-watchdog.py fix-ci-vulkan-headers.py \
         fix-gpu-ci-host-turnip.py; do
  [ -f "$E/dump/wsl/$n" ] && tr -d '\r' < "$E/dump/wsl/$n" > "$DEST/scripts/wsl/$n"
done

echo "== secret scan"
if grep -rn -I -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$]|BEGIN (RSA |EC |)PRIVATE KEY|UNIQUE_CHIP_ID_REDACTED|0xce854c9a|FASTBOOT_SERIAL_REDACTED' "$DEST"; then
  echo "secret-like content found: not committing"; exit 1
fi
echo clean
git add "$DEST"
git status --short | head -15
if [ "${1:-}" = "--push" ]; then
  git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
    "progress 2026-11-04: GPU plugin CI unblocked five times, stopped by macOS minutes

The plugin-only pipeline now builds the host Turnip, installs the Vulkan headers, stubs the
check-quartzcore-turnip-cache-host script this revision calls but does not ship, builds the
host bridge, and relaxes the one watchdog assertion that is deterministic-zero on a runner.
Every other host check passes. The last two runs were cancelled exactly fifteen minutes in
with no competing run, which is the macOS minutes limit, so the addon is not built yet.
Includes the one-command installer for the next successful run."
  git push -q origin main
  git log --oneline -1
fi
