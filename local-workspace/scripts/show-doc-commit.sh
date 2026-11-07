#!/bin/bash
# Files and zh doc diff of UniXNU commit a3faa4a43 (iOS/iPadOS restore images) and 2d0d39fa6 (Turnip GMEM fix).
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
for c in a3faa4a43 2d0d39fa6; do
  echo "########## $c"
  curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/UniXNU/UniXNU/commits/$c" | python3 -c '
import json, sys
c = json.load(sys.stdin)
print(c["commit"]["message"][:800])
for f in c["files"]:
    print("FILE", f["filename"], f["status"], "+%d -%d" % (f["additions"], f["deletions"]))
for f in c["files"]:
    if "/zh/" in f["filename"] or not f["filename"].startswith("docs/"):
        p = f.get("patch", "")
        print("=====", f["filename"]); print(p[:3500])
'
done
