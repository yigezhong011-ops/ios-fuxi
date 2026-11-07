#!/bin/bash
# Read-only: latest V2, every USB document and how the board uses the driver. Nothing from the clone is run.
cd /root/fuxi/ref-fuxi-v2 || exit 1
old=$(git rev-parse origin/V2); timeout 90 git fetch -q origin 2>&1 | tail -1; V=origin/V2
echo "was ${old:0:10} now $(git rev-parse --short=10 $V)"
git log $old..$V --date=iso --format='%h %ad %s' | cut -c1-110
git log $V -6 --date=iso --format='%h %ad %s' | cut -c1-110
echo "=== files with usb in name or md text"
git ls-tree -r --name-only $V | grep -iE 'usb'
git grep -il 'usb' $V -- '*.md' '*.txt' | sed "s#$V:##"
echo "=== USB-RESTORE changed since last read?"; git diff --stat $old $V -- USB-RESTORE-20261102.md | tail -1
git diff $old $V -- USB-RESTORE-20261102.md | grep -E '^[+-]' | cut -c1-200 | head -40
echo "=== README usb lines"; git show $V:README.md | grep -n -i 'usb' | cut -c1-260
echo "=== porting.toml usb area"; git show $V:porting.toml | grep -n -iE 'usb|cdc' | cut -c1-320 | head -20
echo "=== board usb"; git show $V:board.toml | grep -n -iE 'usb' | cut -c1-200
echo "=== status rows code"; git show $V:package/FuxiUsbCompat.c | sed -n 75,243p | cut -c1-140
echo "=== run script"; git show $V:scripts/run-fuxi-usb-kernel.py | sed -n 1,91p | cut -c1-130
