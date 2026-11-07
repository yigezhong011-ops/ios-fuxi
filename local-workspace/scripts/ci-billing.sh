#!/bin/bash
# Show Actions billing / usage for yigezhong011-ops (needs a token that can read billing).
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
for u in /users/yigezhong011-ops/settings/billing/actions /users/yigezhong011-ops/settings/billing/usage; do
  echo "== $u"
  curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" "https://api.github.com$u" | head -c 1500
  echo
done
echo "== repo visibility"
curl -s -H "Authorization: Bearer $TOKEN" https://api.github.com/repos/yigezhong011-ops/unixnu-ci | grep -E '"(private|visibility)"'
