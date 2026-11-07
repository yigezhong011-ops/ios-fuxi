#!/bin/bash
# t32 author's device repo vs the user's fork: latest commits, defconfigs, and whether GPU components are pinned there.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1"; }
for rb in ljhhkx529/unixnu-fuxi:old ljhhkx529/unixnu-fuxi:main yigezhong011-ops/unixnu-fuxi:fts-touch; do
  r=${rb%%:*}; b=${rb##*:}
  echo "### $rb"
  api "$r/commits?sha=$b&per_page=4" | python3 -c 'import json,sys; [print("  ", c["sha"][:9], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90]) for c in json.load(sys.stdin)]'
  api "$r/contents/configs?ref=$b" | python3 -c 'import json,sys; print("   configs:", " ".join(e["name"] for e in json.load(sys.stdin)))'
  api "$r/contents?ref=$b" | python3 -c 'import json,sys; print("   root:", " ".join(e["name"] for e in json.load(sys.stdin)))'
  for f in unixnu.lock feeds.toml; do
    raw "$r/$b/$f" 2>/dev/null | grep -nE -B1 -A3 'Adreno|Metal|GopFramebuffer' | head -20 | sed "s/^/   $f: /"
  done
done
