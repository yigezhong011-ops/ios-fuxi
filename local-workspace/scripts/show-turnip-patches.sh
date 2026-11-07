#!/bin/bash
# How build-turnip-darwin.py at 793d records and applies the Mesa patch list. Read-only.
cd /root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git show $R:scripts/build-turnip-darwin.py | grep -n -E 'patch|sequence' | cut -c1-170 | head -40
L=$(git show $R:scripts/build-turnip-darwin.py | grep -n 'patch sequence differs' | head -1 | cut -d: -f1)
git show $R:scripts/build-turnip-darwin.py | sed -n "$((L-40)),$((L+25))p" | cut -c1-170
echo "== pins keys"; git show $R:scripts/data/adreno-compiler-inputs.json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(list(d)); print({k:(v if not isinstance(v,(list,dict)) else type(v).__name__) for k,v in d.items()})'
git grep -n -E "adreno-compiler-inputs|\['patches'\]|\"patches\"" $R -- scripts | sed "s/^$R://" | cut -c1-150 | head -20
