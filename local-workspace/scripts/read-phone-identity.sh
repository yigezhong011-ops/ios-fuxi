#!/bin/bash
# Read-only: how the author's trees implement phone_identity / phone_model, and what they say on the red bar.
cd /root/fuxi || exit 1
ls -d ref-* src-* 2>/dev/null | tr '\n' ' '; echo
for r in ref-fuxi-v2 src-unixnu src-fuxi ref-gopfb; do
  [ -d "$r/.git" ] || continue
  echo "===== $r $(git -C $r log -1 --format='%h %ad %s' --date=short | cut -c1-90)"
  for b in $(git -C $r for-each-ref --format='%(refname:short)' | head -12); do printf '%s: ' "$b"; git -C $r grep -l -E 'phone_identity|phone_model|phone-identity|phone-model' "$b" 2>/dev/null | wc -l; done
  git -C $r grep -n -E 'phone_identity|phone_model|phone-identity|phone-model' 2>/dev/null | cut -c1-190 | head -30
  echo '-- log'
  git -C $r log --all --format='%h %ad %an %s' --date=short -i --grep='phone.identity\|phone_model\|red bar\|status bar\|statusbar\|45025538\|红条\|subtype' | cut -c1-120 | head -14
done
echo '===== docs'
grep -n -r -I -E 'phone_identity|phone_model|45025538' /mnt/e/DSH-Fuxi/share-for-author /mnt/e/DSH-Fuxi/read 2>/dev/null | cut -c1-180 | head -12
