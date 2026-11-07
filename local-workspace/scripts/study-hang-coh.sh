#!/bin/bash
# Read-only: the IO coherence probe that runs in the hang window, and any upstream fix for it.
K=/root/fuxi/t50/kernel.macho
ls -d /root/fuxi/*/.git 2>/dev/null | sed 's/.git$//' | tr '\n' ' '; echo
echo "=== source mentions"
for r in $(ls -d /root/fuxi/*/.git 2>/dev/null | sed 's/\/.git$//'); do
  n=$(git -C $r grep -l -I -E 'coherenceProbe|\[coherence\]|ioCoherent.*[Pp]robe|coherence probe' HEAD 2>/dev/null | head -6)
  [ -n "$n" ] && { echo "-- $r"; echo "$n" | cut -c1-110; }
done
echo "=== commit subjects about it"
for r in $(ls -d /root/fuxi/*/.git 2>/dev/null | sed 's/\/.git$//'); do
  git -C $r log --all -i --since=2026-10-20 --format="$(basename $r) %h %ad %s" --date=format:%m-%d -E --grep='coheren|snoop|hang|stall|logo|freeze|zap|secure.?mode|tcsr|write.?stream|cache.?coher' 2>/dev/null | cut -c1-140 | head -14
done
echo "=== t50 symbols"
llvm-nm $K | grep -iE 'coheren|snoop|ioCoh' | cut -c1-110 | head -20
strings -a $K | grep -iE 'coherence' | cut -c1-140 | head -14
