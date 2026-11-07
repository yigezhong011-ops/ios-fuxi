#!/bin/bash
# Read-only: did a local kernel build ever work here, and what does the build need.
E=/mnt/e/DSH-Fuxi
cd /root/build/fuxi || exit 1
echo "=== BUILD-PROGRESS head"; sed -n 1,50p BUILD-PROGRESS.md | cut -c1-170
echo "=== AGENTS build section"; sed -n 1,40p AGENTS.md | cut -c1-170
echo "=== tree state"; cd /root/build/unixnu; ls out/fuxi/tree | head -30 | tr '\n' ' '; echo; ls out/fuxi/tree/build 2>/dev/null | head -20 | tr '\n' ' '; echo; cat out/state.json | cut -c1-300; echo
grep -nE 'Darwin|platform\.system|sys\.platform|xcrun|host_os|is_macos|macos' unixnu | cut -c1-140 | head -14
ls scripts | grep -iE 'toolchain|xnu|kernel' | head -14 | tr '\n' ' '; echo
echo "=== earlier notes"
grep -lE 'build kernel|本地编|local kernel' $E/*.md 2>/dev/null | head
grep -nE 'build kernel|本地编内核|WSL.*(kernel|内核)|内核.*(WSL|Linux)' $E/*.md 2>/dev/null | cut -c1-190 | head -14
echo "=== reference artifact"
T=$(tr -d '\r\n ' < $E/token2.txt)
curl -fsSL -H "Authorization: Bearer $T" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/artifacts?name=unixnu-fuxi-kernel&per_page=3' | python3 -I -c "
import json,sys
j=json.load(sys.stdin); print(j['total_count']); [print(a['created_at'][:16],a['size_in_bytes']//1048576,'expired' if a['expired'] else 'live',a['workflow_run']['id']) for a in j['artifacts']]"
echo "=== shim origin"; ls -la /usr/bin/xcrun | cut -c20-; sed -n 8,22p /usr/bin/xcrun | cut -c1-110
ls -la /opt 2>/dev/null | tail -5; ls /root/.local/bin 2>/dev/null | head; ls /root/fuxi/ux /root/fuxi/ux/out 2>/dev/null | head -14 | tr '\n' ' '; echo
