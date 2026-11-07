#!/bin/bash
# Read only: how the plugin finds its slide and arch, which source built the daily plugin, and the CI inputs.
A=/root/fuxi/src-adrenometal; F=NativeAdrenoMetalPlugin.mm; T=ce63701
git -C $A show $T:$F | sed -n 288,316p | cut -c1-150
echo '== daily addon build record'
find /root/fuxi/t50-gpu7 /root/fuxi/plugin-try -maxdepth 4 -iname 'gpu-build.json' 2>/dev/null | head -4 | while read j; do echo $j; cut -c1-500 "$j"; echo; done
git -C /root/fuxi/plugin-try log --oneline -2 2>/dev/null | cut -c1-90
git -C /root/fuxi/plugin-try remote -v 2>/dev/null | head -1 | cut -c1-80
find /root/fuxi/t50-gpu7 -maxdepth 6 -iname '*AdrenoMetal*' 2>/dev/null | cut -c1-110 | head -6
echo '== CI workflow'
W=/root/fuxi/unixnu-ci; ls /root/fuxi | grep -iE '^(unixnu-ci|ci)' ; [ -d $W ] && { ls $W/.github/workflows | head; f=$(ls $W/.github/workflows/* | head -1); grep -n -E 'workflow_dispatch|^ +[a-z_]+:$|description|default:|ref:|repository:|patch |run: ' "$f" | cut -c1-130 | head -50; }
echo '== helpers in other revisions'
for r in $(git -C $A log --format=%h -n 400 -- $F | sed -n '1p;80p;200p'); do echo "$r readTask $(git -C $A show $r:$F | grep -c 'static bool readTask') writeTask $(git -C $A show $r:$F | grep -c 'static bool writeTask')"; done
