#!/bin/bash
# Red shows as blue with the new plugin: read the log and the plugin's framebuffer-format code. Read-only.
L=$(ls -t /mnt/e/DSH-Fuxi/logs/gpu-fix-*.log | head -1); echo "log $L"
echo "== panic lines"; grep -a -n -i 'panic' "$L" | cut -c1-170
echo "== gpu / metal lines"; grep -a -n -i -E 'metal|adreno|gpu|kgsl|m2v|bgra|framebuffer|pixel.?format|swap' "$L" | cut -c1-170 | head -60
echo "== log tail"; tail -8 "$L" | cut -c1-170
cd /root/fuxi/src-adrenometal; PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
echo "== plugin: format code at pin"
git show $PIN:NativeAdrenoMetalPlugin.mm | sed -n '74,100p;336,372p' | cut -c1-210
echo "== sheng-fb-bgra / TU_DEBUG / BGRA in pin"
git grep -n -E 'sheng-fb-bgra|sheng-tu-debug|TU_DEBUG' $PIN | sed "s/^$PIN://" | cut -c1-200 | head -20
echo "== patchFramebufferBranch uses"; git grep -n 'patchFramebufferBranch' $PIN | sed "s/^$PIN://" | cut -c1-200
echo "== later upstream commits touching bgra / swapped colour"
git log --format='%h %cI %s' $PIN..origin/HEAD --grep='BGRA\|bgra\|swizzle\|colou\?r\|red and blue\|channel' -i | cut -c1-120 | head -20
echo "== boot-arg strings in kernels"
for k in /root/fuxi/t50-mine/kernel.macho /root/fuxi/t36-bl2/kernel.macho; do echo "$k"; strings -a $k | grep -E 'sheng-fb|sheng-tu|sheng-gpu-preempt|fb-gpu|BGRA|bgra' | cut -c1-120 | sort -u | head -15; done
echo "== old plugin has these?"; cd /tmp/ga
for t in old new; do echo "$t: $(strings -a $t/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal | grep -E 'sheng-fb|sheng-tu|TU_DEBUG|sysmem' | cut -c1-100 | sort -u | tr '\n' '|')"; done
