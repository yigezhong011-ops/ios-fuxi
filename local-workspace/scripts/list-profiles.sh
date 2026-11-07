#!/bin/bash
# Upstream OS profiles, and the iOS 16 profile's settings if one exists.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/UniXNU/UniXNU/$1"; }
api 'contents/profiles/os?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin)]'
for p in $(api 'contents/profiles/os?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin) if e["name"].startswith("ios")]'); do
  echo "### $p"
  api "contents/profiles/os/$p?ref=main" | python3 -c 'import json,sys; [print(" ", e["name"]) for e in json.load(sys.stdin)]'
  curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/UniXNU/UniXNU/main/profiles/os/$p/os.toml" 2>/dev/null | head -40
done
