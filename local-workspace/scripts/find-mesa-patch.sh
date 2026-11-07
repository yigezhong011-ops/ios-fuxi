#!/bin/bash
# Read only: applies the branch's recorded Mesa patches in a scratch tree to find the one that fails, and shows how build-boot-runtime calls them.
U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64; W=/root/fuxi/mesa-try
git -C $U show $B:scripts/build-boot-runtime.py | sed -n 74,92p | cut -c1-130
git -C $U show $B:scripts/data/adreno-compiler-inputs.json > /tmp/aci.json
python3 -I -c "import json; [print(p) for p in json.load(open('/tmp/aci.json'))['patches']]" > /tmp/mp.txt; cat /tmp/mp.txt | cut -c1-80
for p in $(cat /tmp/mp.txt); do
  git -C $U show $B:$p > /tmp/one.patch 2>/dev/null || { echo "NOT IN TREE $p"; continue; }
  n=$(grep -cE '^(---|\+\+\+) ([^ab/]|/dev/null|dev/null)' /tmp/one.patch)
  odd=$(grep -nE '^(---|\+\+\+) .*dev/null|^(---|\+\+\+) [^ab/]' /tmp/one.patch | head -4 | cut -c1-90 | tr '\n' ';')
  echo "$n $p $odd"
done
