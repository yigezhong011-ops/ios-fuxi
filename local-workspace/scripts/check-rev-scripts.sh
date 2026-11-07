#!/bin/bash
# Which plugin build scripts exist at a UniXNU revision (build-boot-runtime.py with build_plugin, or the older chain).
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
REV=${1:-793d6bddf7}
for f in build-boot-runtime.py build-turnip-darwin.py build-adreno-metal-plugin.py build-adreno-metal-bridge.py make-gpu-addon.py \
         fetch-adreno-inputs.py prepare-adreno-compiler.py requirements-adreno-compiler.txt data/adreno-compiler-inputs.json \
         data/gpu-metal-vulkan-inputs.json mesa_patch_identity.py; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/UniXNU/$REV/scripts/$f")
  echo "$code $f"
done
curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/UniXNU/$REV/scripts/build-adreno-metal-plugin.py" | grep -nE "argparse|--target|mesa-work|SystemExit\('Build Turnip" | head
grep -c . /dev/null
