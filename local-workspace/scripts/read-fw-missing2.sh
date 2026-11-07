#!/bin/bash
# Read-only for E:. Fetches into the WSL copy only: does any upstream branch of unixnu carry AdvancedLogViewLib?
U=/root/fuxi/fw/unixnu; F=/root/fuxi/fw/uefi-fuxi
git -C "$U" remote -v | head -2 | sed -E 's#//[^@/]*@#//#' | cut -c1-90
git -C "$U" fetch -q origin 2>&1 | tail -2 | cut -c1-120
git -C "$U" for-each-ref --format='%(refname:short) %(committerdate:short)' refs/remotes | head -12
git -C "$U" log --all --format='%h %ad %s' --date=short -- 'package/UniXNUPkg/Library/AdvancedLogViewLib/*' | head -5 | cut -c1-100
for r in $(git -C "$U" for-each-ref --format='%(refname)' refs/remotes | head -12); do n=$(git -C "$U" ls-tree -r --name-only "$r" 2>/dev/null | grep -c AdvancedLogViewLib); echo "$r $n"; done
echo '== header anywhere'; find /root/fuxi/fw/uefi-fuxi /root/fuxi/fw/unixnu -name 'AdvancedLogViewLib.h' -not -path '*/Build/*' 2>/dev/null | head
echo '== users, in the dsc and fdf'; grep -n -E 'FuxiUefiLogDxe|FuxiUfsLogDxe' "$F/Platforms/Xiaomi/fuxiPkg/fuxi.dsc" "$F/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" "$F/Platforms/Xiaomi/fuxiPkg/fuxi.fdf" 2>/dev/null | cut -c50-160
grep -n -E 'AdvancedLogView[A-Za-z]* *\(' "$F"/Platforms/Xiaomi/fuxiPkg/Drivers/Fuxi*LogDxe/*.c | cut -c50-170
echo '== was the booted firmware built with the log drivers? names in the loader FD'
ls -la /root/fuxi/t50-wall17 2>/dev/null | head -4 | cut -c24-
