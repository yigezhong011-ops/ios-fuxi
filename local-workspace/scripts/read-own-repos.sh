#!/bin/bash
# Read only: visibility and licence of the user's GitHub repositories.
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
curl -s -H "Authorization: Bearer $T" "https://api.github.com/user/repos?per_page=100&affiliation=owner" > /tmp/own-repos.json
python3 -I - <<'EOF'
import json
for r in json.load(open('/tmp/own-repos.json')):
    print(r['name'], 'private' if r['private'] else 'public', 'fork' if r['fork'] else 'own', (r.get('license') or {}).get('spdx_id'))
EOF
rm -f /tmp/own-repos.json
