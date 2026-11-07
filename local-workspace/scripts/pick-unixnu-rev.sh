#!/bin/bash
# UniXNU main commits around 2026-11-01/02 (to pin a revision the t32 author's device repo still builds against), and the
# AdrenoMetal / GopFramebuffer submodule revisions each would use.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
api 'UniXNU/UniXNU/commits?sha=main&since=2026-10-31T00:00:00Z&until=2026-11-02T12:00:00Z&per_page=40' | python3 -c '
import json, sys
for c in json.load(sys.stdin):
    print(c["sha"][:12], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:90])'
