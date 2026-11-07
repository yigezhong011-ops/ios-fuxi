#!/bin/bash
# Upstream AdrenoMetal bridge patches against metal2vulkan: which ones touch no-copy buffers / shadows / linear images.
W=/root/fuxi/upstream-am; mkdir -p $W/patches; cd $W
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/UniXNU/AdrenoMetal/$1"; }
api 'contents/bridge/patches?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin)]' > patches.txt
wc -l patches.txt
while read -r n; do
  curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/AdrenoMetal/main/bridge/patches/$n" -o "patches/$n"
done < patches.txt
echo "### patches mentioning no-copy / shadow / linear image"
grep -l -iE 'no-copy|shadow|linear image' patches/* | xargs -n1 basename
echo "### commits on bridge/patches touching 'shadow'"
api 'commits?path=bridge/patches&per_page=40' | python3 -c 'import json,sys; [print(c["sha"][:9], c["commit"]["committer"]["date"][:10], c["commit"]["message"].splitlines()[0][:100]) for c in json.load(sys.stdin)]'
