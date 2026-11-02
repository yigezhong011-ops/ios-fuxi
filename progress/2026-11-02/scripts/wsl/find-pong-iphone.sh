#!/bin/bash
# What pong recorded about running with the iPhone 16 Pro identity (layout, Dynamic Island, MobileGestalt cache); read-only
python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-grep-tree.py Chengdong-Yu/UniXNU-pong main 'gestalt|identity|iphone|island|layout|ipados18|migration' | grep -v -E '^tree' | head -40
for q in 'repo:Chengdong-Yu/UniXNU-pong MobileGestalt' 'repo:Chengdong-Yu/UniXNU-pong iPhone17,1' 'repo:Chengdong-Yu/UniXNU-pong 2622' 'repo:Chengdong-Yu/UniXNU-pong Dynamic Island'; do
    echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -15; sleep 3
done
