#!/bin/bash
# Read only: camera and flash in the upstream docs, and repositories in the org named for them.
U=/root/fuxi/up-latest; B=origin/main
echo '== devices and pages that mention them, counts'
git -C $U grep -c -iE 'camera|\bcamss\b|\bcci\b|\bisp\b|torch|flashlight|led flash|flash led' $B -- docs/devices docs/porting docs/drivers ':!docs/zh' | sed "s#^$B:docs/##" | sort -t: -k2 -rn | head -16
echo; echo '== the lines'
git -C $U grep -n -iE 'camera|\bcamss\b|torch|flashlight|led flash|flash led' $B -- docs/porting docs/drivers docs/devices/sheng.md docs/devices/fuxi.md docs/devices/fuxi-oddlylabs.md docs/devices/asteroids.md docs/devices/oneplus13t.md docs/devices/oneplus13t-shad0w23333.md docs/devices/qemu.md ':!docs/zh' | sed "s#^$B:docs/##" | cut -c1-330 | head -30
echo; echo '== any working device'
git -C $U grep -n -iE '(camera|torch|flashlight).{0,60}(work|captur|preview|shows|opens|lights|on\b)' $B -- docs/devices ':!docs/zh' | sed "s#^$B:docs/##" | cut -c1-280 | head -20
echo; python3 -I -c "
import json
for r in json.load(open('/tmp/ux-repos.json')):
    n=r['name']
    if any(k in n.lower() for k in ('cam','flash','torch','led','isp')): print(n, r['pushed_at'], (r['description'] or '')[:70])"
