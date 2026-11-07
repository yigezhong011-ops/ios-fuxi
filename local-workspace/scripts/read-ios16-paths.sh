#!/bin/bash
# Read-only: what iOS 16 support exists upstream, in the fuxi tree and on disk.
E=/mnt/e/DSH-Fuxi; cd /root/fuxi || exit 1
echo "== WSL space"; df -h /root /mnt/e 2>/dev/null | cut -c1-70
du -sh /root/fuxi 2>/dev/null
echo "== src-unixnu"
git -C src-unixnu log -1 --format='%h %ad %s' --date=short | cut -c1-90
git -C src-unixnu ls-tree -d --name-only HEAD profiles/os/ 2>/dev/null | head -20
git -C src-unixnu ls-tree -r --name-only HEAD 2>/dev/null | grep -i -E '20H392|16\.7|darwin22|ios-16|ios16' | cut -c1-120 | head -24
git -C src-unixnu grep -n -E '20H392|16\.7\.16' -- 'docs/zh/guide/requirements.md' 'profiles' 2>/dev/null | cut -c1-170 | head -8
echo "== device records with iOS"
git -C src-unixnu ls-tree -r --name-only HEAD docs/.vitepress/device-records 2>/dev/null | head -20
git -C src-unixnu grep -l -E 'iPhone10,3|20H392' -- docs/.vitepress/device-records 2>/dev/null | head
echo "== fuxi branches"
git -C ref-fuxi-v2 grep -n -E '20H392|16\.7|darwin22|Darwin22' origin/old origin/V2 2>/dev/null | cut -c1-170 | head -12
git -C ref-sad-fuxi log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-90
git -C ref-sad-fuxi grep -n -E '20H392|16\.7|phone_model' 2>/dev/null | cut -c1-170 | head -8
echo "== local files"
ls -la $E/*.simg $E/fuxi-csfix*.img 2>/dev/null | cut -c24-
find $E -maxdepth 3 \( -iname '*iPhone10,3*' -o -iname '*20H392*' -o -iname '*.ipsw' -o -iname 'gles-root*' \) 2>/dev/null | cut -c1-120 | head -12
find /root -maxdepth 3 \( -iname '*iPhone10,3*' -o -iname '*20H392*' -o -iname '*.ipsw' \) 2>/dev/null | cut -c1-120 | head -8
du -sh $E/logs $E/ux-out $E/dump $E/unixnu-build $E/backup 2>/dev/null
ls -S -l $E/*.img 2>/dev/null | head -5 | cut -c24-
