#!/bin/bash
# Local dry run: apply the bridge's translator patches to metal2vulkan, then 0025, to see if it fits without 0021-0024. Nothing is pushed.
set -uo pipefail
A=/root/fuxi/src-adrenometal; M=/root/fuxi/m2v-try
U=/root/fuxi/unixnu-pin;
[ -d $U ] || { git -C /root/fuxi/up-latest rev-parse HEAD >/dev/null; mkdir -p $U; git -C $U init -q; git -C $U fetch -q --depth=1 https://github.com/UniXNU/UniXNU 793d6bddf7ea90678e3a61e2b2bd4350e5fdce16 && git -C $U checkout -q --detach FETCH_HEAD; }
git -C $U log -1 --format='UniXNU %h %ad' --date=short
sed -n 24,50p $U/scripts/build-adreno-metal-bridge.py | cut -c1-120
grep -n -E "git.*apply|'am'|apply" $U/scripts/build-adreno-metal-bridge.py | cut -c1-150 | head -6
T=$(python3 -I -c "import json; print(json.load(open('$U/scripts/data/gpu-metal-vulkan-inputs.json'))['translator'])"); echo "translator $T" | cut -c1-200
rm -rf $M; mkdir -p $M; git -C $M init -q
git -C $M fetch -q --depth=1 https://github.com/steelbrain/metal2vulkan 624bab3918de5b978e1101517abca2b4fa42 2>&1 | tail -1
git -C $M rev-parse FETCH_HEAD 2>/dev/null | cut -c1-12
