#!/bin/bash
# GPU leads: sheng's client list (same SoC and GPU), the upstream GPU-fix branch notes (read-only)
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
echo "### sheng clients"
python3 /root/fuxi/cs.py 'repo:UniXNU/UniXNU-sheng clients' | head -15
sleep 3
echo "### commit d6bd3dd (Document current GPU scheduling and Metal behavior)"
python3 /root/fuxi/gcd.py UniXNU/UniXNU d6bd3ddc9a docs/zh | head -120
