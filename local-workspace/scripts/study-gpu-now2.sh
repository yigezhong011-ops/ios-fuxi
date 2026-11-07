#!/bin/bash
# Evidence for the GPU plan: commit bodies, slot limit, and whether a newer plugin can run on the t50 kernel. Read-only.
M=/root/fuxi/src-adrenometal; A=/root/fuxi/src-adreno740; U=/root/fuxi/src-unixnu
echo "== pins' dates"
git -C $M log -1 --format='plugin pin %h %ad' --date=short 7e0d3d2
git -C $U log -1 --format='unixnu pin %h %ad' --date=short 793d6bddf7
git -C $A log -1 --format='driver pin %h %ad' --date=short 759d646
echo "== key plugin commits"
for c in 8c1ea13 5a50581 722b9c1 0f17e74; do git -C $M log -1 --format='--- %h %s%n%b' $c | cut -c1-200 | head -16; done
echo "== all plugin commits mentioning widgets, white, blank, sample count or poster"
git -C $M log --format='%h %ad %s' --date=short -i --grep='widget\|white\|blank\|poster\|msaa\|multisample' 7e0d3d2..origin/main | cut -c1-120 | head -20
echo "== slot limit in the driver at our pin and at head"
for r in 759d646 origin/main; do
  echo "-- $r"
  git -C $A grep -n -E 'kMaxClients|MaxClients|kClientSlots|kSlots|NATIVE_ADRENO_(MAX_)?(CLIENTS|SLOTS)|kIOReturnBusy|e00002d5' $r -- . 2>/dev/null | sed "s/^$r://" | cut -c1-165 | head -10
done
echo "== docs on slots and widgets at head"
git -C $U grep -n -i -E 'slot|widget|first come|four (gpu )?client' origin/main -- docs/guide docs/porting 2>/dev/null | sed 's/^origin\/main://' | grep -i -E 'gpu|metal|widget' | cut -c1-210 | head -16
echo "== kernel methods the head plugin needs vs t50 kernel"
git -C $A diff --stat 759d646 origin/main -- . 2>/dev/null | tail -1
git -C $M grep -n -E 'kMethod *=|0x7[0-9a-f]{3}\b' origin/main -- NativeAdrenoMetalPlugin.mm 2>/dev/null | sed 's/^origin\/main://' | cut -c1-140 | head -10
