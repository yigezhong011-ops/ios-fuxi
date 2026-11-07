#!/bin/bash
# Adds today's wallpaper and GPU progress on top of the fork's old branch. Explicit list, secret scan, normal push: no force.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; L=$E/logs; R=/root/fuxi/fork-work; D=progress/2026-11-07-gpu-wallpaper
U=https://github.com/yigezhong011-ops/unixnu-fuxi.git
AUTH="Authorization: Basic $(printf 'x-access-token:%s' "$(tr -d '\r\n ' < $E/token2.txt)" | base64 -w0)"
rm -rf "$R"
git -c "http.https://github.com/.extraheader=$AUTH" clone -q --single-branch --branch old --no-recurse-submodules "$U" "$R"
cd "$R"
BEFORE=$(git rev-parse HEAD)
mkdir -p "$D/scripts" "$D/shots"
tr -d '\r' < $S/progress-1107-metal.md > "$D/README.md"
for f in patch-t50-grant.py make-t50-grant.sh make-t50-g7plug.sh make-t50-daily-g7grant.sh patch-t50-gpu7.py make-t50-gpu7.sh make-t50-wallcat.sh make-t50-storefix2.sh touch-cave2.c patch-t50-tap.py make-t50-tap.sh ctl-run.ps1 metal-kinds.py read-stretch.sh run-metal-ab2.ps1 run-tile-tap2.ps1 pull-wall.ps1; do
  tr -d '\r' < "$S/$f" > "$D/scripts/$f"
done
cp "$L/shot-t50-auto-g7grant-115905-pride.png" "$D/shots/pride-grant-old-plugin.png"
cp "$L/shot-t50-auto-g7plugrant-114915-pride.png" "$D/shots/pride-grant-new-plugin.png"
cp "$L/shot-t50-auto-g7grant-113312-scroll4.png" "$D/shots/gallery-unity-filled.png"
cp "$L/shot-t50-auto-g7grant-121944-hello.png" "$D/shots/hello-black.png"
cp "$L/shot-attach-122411-notes.png" "$D/shots/daily-candidate-right-tap.png"
F=$(git ls-files -mo --exclude-standard)
echo "$F"
if echo "$F" | grep -E '\.(img|bin|macho|ipsw|key|pem|plist)$|data-raw|lscan|token'; then echo 'forbidden file'; exit 1; fi
if echo "$F" | xargs -d '\n' grep -n -I -i -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|x-access-token:[^$%]|BEGIN (RSA |EC |)PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo 'secret-like content: not committing'; exit 1; fi
echo "$F" | xargs -d '\n' git add --
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "progress 2026-11-07: sandbox grant lets the gallery posters reach the GPU

The grant list lacked KaleidoscopePoster, PridePosterExtension and HelloPosterExtension.
With the longer list Unity tiles fill and Pride draws on the old plugin; the 11-05 plugin draws Pride black.
Hello is still black and the lag is unsolved. Temp boots only, mostly one run each; nothing flashed."
git -c "http.https://github.com/.extraheader=$AUTH" push -q origin old
AFTER=$(git rev-parse HEAD)
git merge-base --is-ancestor "$BEFORE" "$AFTER" && echo 'history kept'
echo "remote old $(git -c "http.https://github.com/.extraheader=$AUTH" ls-remote origin refs/heads/old | cut -c1-12), local $(echo $AFTER | cut -c1-12), before $(echo $BEFORE | cut -c1-12)"
git show --stat --format='%h %s' HEAD | tail -1
