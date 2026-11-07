#!/bin/bash
# Read only: the licence files of the user's repositories and each fork's parent.
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt); O=yigezhong011-ops
for r in fuxi-touch fuxi-touch-ci hakios-fuxi hakios-uefi-fuxi ios-fuxi NativeAdreno-fuxi UniXNU unixnu-ci unixnu-fuxi unixnu-star; do
  H="Authorization: Bearer $T"
  curl -s -H "$H" https://api.github.com/repos/$O/$r > /tmp/r.json
  python3 -I -c 'import json; r=json.load(open("/tmp/r.json")); print("==", r["name"], "default", r["default_branch"], "size KB", r["size"], "parent", (r.get("parent") or {}).get("full_name"), "parent licence", ((r.get("parent") or {}).get("license") or {}).get("spdx_id"))'
  B=$(python3 -I -c 'import json; print(json.load(open("/tmp/r.json"))["default_branch"])')
  curl -s -H "$H" "https://api.github.com/repos/$O/$r/contents?ref=$B" > /tmp/c.json
  python3 -I -c 'import json; c=json.load(open("/tmp/c.json")); print("  files:", [x["name"] for x in c if isinstance(x,dict) and any(k in x["name"].upper() for k in ("LICEN","COPY","NOTICE","README"))] if isinstance(c,list) else c)'
  for f in LICENSE LICENSE.md LICENSE.txt COPYING; do
    curl -s -H "$H" -H 'Accept: application/vnd.github.raw' "https://api.github.com/repos/$O/$r/contents/$f?ref=$B" > /tmp/l.txt
    if ! grep -q '"Not Found"' /tmp/l.txt; then echo "  $f: $(wc -c < /tmp/l.txt) bytes"; head -5 /tmp/l.txt | cut -c1-100 | sed 's/^/    /'; break; fi
  done
done
rm -f /tmp/r.json /tmp/c.json /tmp/l.txt
