#!/bin/bash
# Read-only: local kernel build ability, last CI kernel failure, disk space.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt); A=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
api() { curl -fsSL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' "$@"; }
echo "=== space"; df -h /root /mnt/e | awk '{print $1,$2,$4,$6}'; uname -m; nproc; free -g | sed -n 2p
echo "=== local trees with xnu"
ls -d /root/build /root/build/* /root/hakios-xnu-kernel 2>/dev/null | head -14
find /root /var/tmp -maxdepth 5 -type f -name 'osfmk' 2>/dev/null | head -1
find /root /var/tmp -maxdepth 6 -type d -name osfmk -not -path '*/BUILD/*' 2>/dev/null | head -8
find /root /var/tmp -maxdepth 7 -type f -name 'sched_clutch.c' 2>/dev/null | head -5
echo "=== toolchains"
ls -d /var/tmp/unixnu-toolchain* 2>/dev/null; which clang lld ld64.lld xcrun 2>/dev/null; clang --version 2>/dev/null | head -1
echo "=== built kernels"
find /root -maxdepth 7 -name 'kernel.macho' -path '*out*' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | sort | tail -6
grep -nEi 'macos|linux|xcode|sdk|platform|ubuntu' /root/fuxi/unixnu-pin/docs/zh/porting/build*.md 2>/dev/null | cut -c1-170 | head -8
grep -rnIE 'Kernel builds?|macOS.*kernel|kernel.*macOS' /root/fuxi/unixnu-pin/docs/zh/xnu/*.md 2>/dev/null | cut -c1-170 | head -6
echo "=== runs with kernel step not skipped"
api "$A/actions/runs?per_page=100&event=workflow_dispatch" | python3 -I -c "
import json,sys
print(' '.join(str(r['id']) for r in json.load(sys.stdin)['workflow_runs'] if r['name']=='fuxi GPU build'))" > /tmp/ids
for r in $(cat /tmp/ids); do
  api $A/actions/runs/$r/jobs | python3 -I -c "
import json,sys
for j in json.load(sys.stdin)['jobs']:
    for s in j['steps']:
        if s['name']=='kernel' and s['conclusion'] not in ('skipped',None):
            print($r, j['id'], s['conclusion'], (s['started_at'] or '')[:16], (s['completed_at'] or '')[11:16])"
done | head -14
