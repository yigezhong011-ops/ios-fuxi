#!/bin/bash
# Read-only: can the kernel be built on this Linux host; where CI's last kernel attempt failed.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt); A=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
api() { curl -fsSL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' "$@"; }
echo "=== xcrun"; file -L /usr/bin/xcrun | cut -c1-90; head -c 300 /usr/bin/xcrun | head -8 | cut -c1-110
echo "=== /root/build/unixnu"; cd /root/build/unixnu && git log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-90; ls | tr '\n' ' '; echo
ls -d out/* out/*/tree 2>/dev/null | head; du -sh out 2>/dev/null
echo "=== /root/build/fuxi"; ls /root/build/fuxi | tr '\n' ' ' | cut -c1-500; echo; git -C /root/build/fuxi log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-90; ls /root/build/fuxi/build | head -20 | tr '\n' ' '; echo
echo "=== docs on build host"
D=/root/fuxi/up-latest
git -C $D grep -nIE 'macOS|Xcode|xcodebuild|Linux host|on Linux' origin/main -- docs/getting-started docs/xnu docs/concepts docs/porting/build.md README.md 2>/dev/null | sed 's#origin/main:##' | cut -c1-190 | head -22
git -C $D grep -lE 'MacOSX.*sdk|kernel.*macOS' origin/main -- scripts/build-xnu* unixnu 2>/dev/null | head
echo "=== AGENTS build lines"; grep -nE 'macOS|Linux|WSL|docker|build kernel|xcode|SDK' $E/unixnu-build/fuxi/AGENTS.md | cut -c1-170 | head -16
echo "=== last CI kernel failure 41593531393"
api $A/actions/jobs/125775501110/logs 2>/dev/null > /tmp/cik.log; wc -l /tmp/cik.log
sed -E 's/^[0-9T:.Z-]+ //' /tmp/cik.log | grep -nE ' error: |fatal error|\*\*\* |Traceback|Error [0-9]+$|##\[error\]' | tail -14 | cut -c1-210
echo "=== log tail"; sed -E 's/^[0-9T:.Z-]+ //' /tmp/cik.log | grep -n '##\[error\]' | head -1
