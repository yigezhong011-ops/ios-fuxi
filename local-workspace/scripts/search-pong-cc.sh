#!/bin/bash
# How pong handles Control Center on its iPadOS root with a phone identity: search its repository.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in 'repo:Chengdong-Yu/UniXNU-pong ControlCenter' 'repo:Chengdong-Yu/UniXNU-pong CCUI' 'repo:Chengdong-Yu/UniXNU-pong ui_compat' 'repo:Chengdong-Yu/UniXNU-pong DeviceClassNumber'; do
  echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -8; sleep 3
done
