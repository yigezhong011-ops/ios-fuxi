#!/bin/bash
# Read only: searches the current UniXNU docs for the open problems. Output goes to E: so it can be read in parts.
U=/root/fuxi/up-latest; B=origin/main; O=/mnt/e/DSH-Fuxi/logs/m2v-read/search.txt
g() { echo; echo "##### $1"; git -C $U grep -n -iE "$2" $B -- docs/devices docs/porting docs/drivers docs/zh/drivers ':!docs/zh/devices' | sed "s#^$B:docs/##" | cut -c1-${3:-300} | head -${4:-40}; }
{
git -C $U log -1 --format='docs at %h %ad' --date=short $B
git -C $U ls-tree --name-only $B docs/devices/ | wc -l
g 'GPU hang or stall' 'gpu (hang|stall|lockup|wedge)|hard hang|fence (never|stuck|stall)|ring (stall|hang|stuck)|gpu fault|recover(y|s)? .*gpu|gpu .*recover|froze|frozen|freezes|hangs? (after|when|on) ' 320 45
g 'poster and wallpaper' 'poster|PosterBoard|wallpaper.*(black|draw|metal|render|gallery|tile|thumbnail)|Hello|Kaleidoscope|MetalView' 320 45
g 'cold start, app launch' 'cold (start|launch)|app (launch|open)|first launch|launch time|opens? in|prim(e|ing).*(settings|app)|Settings .*(black|slow|seconds)' 300 25
g 'addon size, payload size' 'addon.*(size|bytes|MiB|grow|limit)|(size|limit).*addon|opt-level|strip.*plugin|plugin.*(size|MiB)|FAT.*free|free clusters|boot image.*(MiB|size)' 260 25
g 'scheduler on SM8550 and others' 'zzyf|Edge scheduler|cluster-type|recommended.cores|sheng-cpu0-park|coreduetd' 260 25
g 'slots' 'aperture|GPU slot|device refused|VkResultCode|ERROR_INITIALIZATION|VK_ERROR|sandbox grant|NativeSandboxGrant' 280 25
} > $O
wc -l $O
grep -c '' $O
