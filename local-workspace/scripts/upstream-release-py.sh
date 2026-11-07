#!/bin/bash
# Upstream `unixnu release` step list: how it builds Turnip, the plugin, the trust bundle and the GPU addon.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
mkdir -p /mnt/e/DSH-Fuxi/read/ci/unixnu-py; cd /mnt/e/DSH-Fuxi/read/ci/unixnu-py
for f in $(api 'UniXNU/UniXNU/contents/scripts/unixnu?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin) if e["name"].endswith(".py")]'); do
  curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/UniXNU/main/scripts/unixnu/$f" -o $f
done
ls
grep -nE 'fetch-adreno-inputs|build-turnip|build-adreno-metal|make-owner-trust|make-gpu-addon|original-system-trust|add-gpu-plugin|gpu.addon|STEPS|def step_|steps = ' *.py | cut -c1-200 | head -40
