#!/bin/bash
# Read only: what the status bar block depends on, in the branch plugin and in the plugin the good boots use.
A=/root/fuxi/src-adrenometal; F=NativeAdrenoMetalPlugin.mm; T=ce63701
echo "== heads $(git -C $A rev-parse --short HEAD)"; git -C $A log --oneline -3 | cut -c1-90
ls /root/fuxi | grep -iE 'plugin|adreno' | head -20
echo '== includes'; git -C $A show $T:$F | sed -n 1,40p | grep -E '^#' | cut -c1-70
echo '== readTask writeTask'; git -C $A show $T:$F | grep -n -A9 -E 'static bool (readTask|writeTask)' | cut -c1-140
echo '== arch and ARC'; git -C $A show $T:$F | grep -n -E '__arm64e__|__bridge|CARenderServerStart|__attribute__\(\(constructor' | cut -c1-130 | head -14
git -C $A ls-tree --name-only $T | head -30
git -C $A show $T:Makefile 2>/dev/null | grep -n -iE 'fobjc-arc|arch|arm64|framework|-O' | cut -c1-130 | head -12
git -C $A show $T:CMakeLists.txt 2>/dev/null | grep -n -iE 'fobjc-arc|arch|arm64|framework' | cut -c1-130 | head -12
git -C $A show $T:build.sh 2>/dev/null | grep -n -iE 'fobjc-arc|arch|arm64|framework' | cut -c1-130 | head -12
echo '== plugin load'; git -C $A grep -n -iE 'SpringBoard|backboardd' $T -- . | cut -c1-170 | head -12
echo '== built plugins'
for d in /root/fuxi/gpu-plugin-m2v /root/fuxi/gpu-plugin-m2v-state /root/fuxi/t50-gpu7; do [ -d $d ] && { echo $d; find $d -maxdepth 3 -iname '*AdrenoMetal*' -type f | head -3; }; done
