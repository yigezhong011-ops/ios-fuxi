#!/bin/bash
# Where "verify_swap failed" comes from (GitHub code search across UniXNU and the fuxi repos), and the source around it.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in '"verify_swap failed"' 'verify_swap org:UniXNU' 'verify_swap repo:ljhhkx529/unixnu-fuxi'; do
  echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -8; sleep 3
done
