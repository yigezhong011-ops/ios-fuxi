#!/bin/bash
# How upstream builds the whole image incl. the GPU plugin: templates/package.sh, sheng's CI workflows, mesa-work preparation.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1"; }
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
echo "### templates/package.sh"
raw UniXNU/UniXNU/main/templates/package.sh | grep -vE '^\s*#|^\s*$' | head -60
echo "### sheng workflows"
api 'UniXNU/UniXNU-sheng/contents/.github/workflows?ref=main' | python3 -c 'import json,sys; [print(" ", e["name"]) for e in json.load(sys.stdin)]'
echo "### who creates .cache/mesa-work"
mkdir -p /root/fuxi/up-scripts; cd /root/fuxi/up-scripts
api 'UniXNU/UniXNU/contents/scripts?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin) if e["name"].endswith(".py")]' > list.txt
grep -iE 'mesa|turnip|adreno|gpu|release|package' list.txt | tr '\n' ' '; echo
for f in $(grep -iE 'prepare.*(mesa|adreno|compiler)|mesa' list.txt); do raw UniXNU/UniXNU/main/scripts/$f > $f; done
grep -l 'mesa-work' *.py 2>/dev/null
