#!/bin/bash
# Read-only: the V2 USB commits and docs.
cd /root/fuxi/ref-fuxi-v2 || exit 1
V=origin/V2
date
echo "=== 172a8ce"; git show --stat --format='%B' 172a8ce | cut -c1-200 | head -40
echo "=== 1190646"; git show --format='%B' 1190646 | cut -c1-170 | head -130
echo "=== 8fb9709"; git show --stat --format='%B' 8fb9709 | cut -c1-200 | head -25
echo "=== board.toml args"; git show $V:board.toml | sed -n 100,125p | cut -c1-200
echo "=== USB-RESTORE"; git show $V:USB-RESTORE-20261102.md | cut -c1-200
echo "=== boot_track"; git show $V:docs/boot_track.md | cut -c1-220
echo "=== comparison report"; git show $V:docs/PORTING_COMPARISON_REPORT.md | cut -c1-200 | sed -n 1,30p
echo "=== README head"; git show $V:README.md | cut -c1-220 | sed -n 1,45p
echo "=== AGENTS"; git show $V:AGENTS.md | cut -c1-220
