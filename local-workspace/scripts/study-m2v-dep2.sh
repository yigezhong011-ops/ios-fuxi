#!/bin/bash
# Read-only: where upstream's two translator methods live, and what the translator pin and patches are at each revision.
R=/root/fuxi/src-adrenometal
cd $R; git log -1 --format='HEAD %h %ad' --date=short; git status -s | head -3
for s in backing_allocation_size with_specialized_name; do echo "== $s"; git log --all --oneline -S"$s" | cut -c1-90 | tail -5; git grep -l "$s" HEAD | cut -c1-90 | head -6; done
L=/root/fuxi/ci-41937514030.log
grep -n -E '624bab39|translator|gpu-reference/metal2vulkan|apply.*metal2vulkan|git .*am ' $L | cut -c30-190 | head -12
cd /root/fuxi/up-latest
grep -rn -E 'translator *=|624bab39|metal2vulkan.*(ref|commit|rev)' scripts/*.py board* drivers.toml *.toml 2>/dev/null | cut -c1-170 | head -8
git log -3 --format='%h %ad %s' --date=short -- scripts/build-adreno-metal-bridge.py | cut -c1-100
U=/root/fuxi/uni-oldci; ls /root/fuxi | grep -i -E 'uni|old' | head
