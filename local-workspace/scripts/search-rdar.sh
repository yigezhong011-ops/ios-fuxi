#!/bin/bash
# Who prints "rdar:45025538" in a red status bar: GitHub code search across UniXNU ports and iOS research repos.
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in '45025538' 'rdar 45025538' '"rdar:" statusbar red emoji springboard' 'SBStatusBarDebug rdar'; do
  echo "### $q"; python3 /root/fuxi/cs.py "$q" | head -10; sleep 3
done
