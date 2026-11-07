#!/bin/bash
# Lists the remotes of local checkouts that concern Metal, plus any branch named like metal2vulkan. Read only.
cd /root/fuxi 2>/dev/null || exit 1
for g in $(find /root/fuxi /mnt/e/DSH-Fuxi/unixnu-build -maxdepth 4 -type d -name .git 2>/dev/null | head -80); do
  d=${g%/.git}
  u=$(git -C "$d" remote -v 2>/dev/null | awk '/fetch/{print $2}' | sed -E 's#https://[^@/]*@#https://#' | tr '\n' ' ')
  echo "$d  $u"
  git -C "$d" branch -a 2>/dev/null | grep -iE 'metal|vulkan|m2v' | sed 's/^/    /'
done
