#!/bin/bash
# Where upstream AdrenoMetal / metal2vulkan emits "makes no linear image", and the plugin's user-client ABI checks.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in 'org:UniXNU "no linear image"' 'org:UniXNU "no-copy buffer"' 'repo:UniXNU/AdrenoMetal kAbiVersion' 'repo:UniXNU/AdrenoMetal abi_version'; do
  echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -12; sleep 4
done
