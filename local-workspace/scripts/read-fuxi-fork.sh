#!/bin/bash
# What the fork holds compared with the local tree. Fetches into a scratch bare clone only; pushes nothing.
B=/root/fuxi/fork-unixnu-fuxi.git; L=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
U=https://github.com/yigezhong011-ops/unixnu-fuxi.git
git ls-remote --heads $U | cut -c1-90
[ -d $B ] || git clone -q --bare $U $B
git -C $B fetch -q origin '+refs/heads/*:refs/heads/*'
for b in $(git -C $B for-each-ref --format='%(refname:short)' refs/heads); do
  echo "== fork $b: $(git -C $B log -1 --format='%h %ad %an %s' --date=short $b | cut -c1-90)"
done
git -C $L fetch -q $B '+refs/heads/*:refs/remotes/fork/*'
for b in $(git -C $L for-each-ref --format='%(refname:lstrip=3)' refs/remotes/fork); do
  echo "local old vs fork/$b: ahead,behind $(git -C $L rev-list --left-right --count old...fork/$b | tr '\t' ',')"
done
echo '--- fork/old commits local old lacks'
git -C $L log --format='%h %ad %an %s' --date=short old..fork/old | cut -c1-100 | head -30
echo '--- local old commits fork/old lacks'
git -C $L log --format='%h %ad %an %s' --date=short fork/old..old | cut -c1-100 | head -10
echo '--- local uncommitted'
git -C $L status --short | cut -c1-80 | head -30
git -C $L diff --stat | tail -5 | cut -c1-90
git -C $L diff --cached --stat | tail -3 | cut -c1-90
echo '--- secret scan of local changes'
git -C $L diff HEAD | grep -a -c -i -E 'ghp_|github_pat_|BEGIN .*PRIVATE KEY|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'
git -C $L status --short | awk '$1=="??"{print $2}' | while read -r f; do (cd $L && grep -l -a -i -E 'ghp_|github_pat_|PRIVATE KEY|AGE-SECRET|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' "$f" 2>/dev/null); done | head
