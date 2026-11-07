#!/bin/bash
# The first UniXNU commit whose AdrenoMetal pin contains the bridge patch 0020 (written host-page textures at any size), and
# whether the kernel user-client ABI header changed between the t36 kernel's base (~793d6bddf7) and that commit.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1"; }
echo "### UniXNU 10-31 12:00Z .. 11-01 06:00Z"
api 'UniXNU/UniXNU/commits?sha=main&since=2026-10-31T12:00:00Z&until=2026-11-01T06:00:00Z&per_page=60' > /root/fuxi/ux-commits.json
python3 - <<'EOF'
import json
for c in json.load(open('/root/fuxi/ux-commits.json')):
    print(" ", c["sha"][:10], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90])
EOF
for rev in 793d6bddf7 $(python3 -c 'import json; [print(c["sha"][:10]) for c in json.load(open("/root/fuxi/ux-commits.json"))]'); do
  AM=$(api "UniXNU/UniXNU/contents/drivers/AdrenoMetal?ref=$rev" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])' 2>/dev/null)
  A7=$(api "UniXNU/UniXNU/contents/drivers/Adreno740?ref=$rev" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])' 2>/dev/null)
  HAS=$(raw "UniXNU/AdrenoMetal/$AM/bridge/patches/0020-written-host-page-textures-in-place-at-any-size.patch" 2>/dev/null | head -c 10 | wc -c)
  ABI=$(raw "UniXNU/Adreno740/$A7/NativeAdrenoABI.h" 2>/dev/null | sha256sum | cut -c1-10)
  echo "$rev AdrenoMetal ${AM:0:10} Adreno740 ${A7:0:10} 0020:$([ "$HAS" -gt 0 ] && echo yes || echo no) ABI.h:$ABI"
done
