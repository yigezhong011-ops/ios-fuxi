#!/bin/bash
# Adreno740 (kernel driver) history since 2026-10-20: which commits touch the user-client interface the plugin and Turnip call.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
echo "### Adreno740 commits"
api 'UniXNU/Adreno740/commits?since=2026-10-18T00:00:00Z&per_page=60' | python3 -c 'import json,sys; [print(c["sha"][:9], c["commit"]["committer"]["date"][:10], c["commit"]["message"].splitlines()[0][:110]) for c in json.load(sys.stdin)]'
echo "### Adreno740 files (headers shared with the plugin)"
api 'UniXNU/Adreno740/contents?ref=main' | python3 -c 'import json,sys; [print(e["name"]) for e in json.load(sys.stdin)]' | tr '\n' ' '; echo
echo "### commits touching NativeAdrenoUserClient.h"
api 'UniXNU/Adreno740/commits?path=NativeAdrenoUserClient.h&per_page=30' | python3 -c 'import json,sys; [print(c["sha"][:9], c["commit"]["committer"]["date"][:10], c["commit"]["message"].splitlines()[0][:110]) for c in json.load(sys.stdin)]'
echo "### AdrenoMetal includes from drivers/Adreno740"
grep -hoE '#include "[^"]+"' /root/fuxi/upstream-am/*.mm | sort -u
