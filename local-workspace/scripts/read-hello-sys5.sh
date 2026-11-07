#!/bin/bash
# Extract every metallib plus Hello's framework binaries from the local image, into a WSL work directory, then read function names.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; O=/root/fuxi/hello-look; cd $O; rm -rf m; mkdir -p m
7z x -y -bso0 -bsp0 -om "$I" '*.metallib' -r >/dev/null 2>&1
7z x -y -bso0 -bsp0 -om "$I" 'System/Library/PrivateFrameworks/HelloPoster.framework/HelloPoster' 'System/Library/PrivateFrameworks/HelloPoster.framework/PlugIns/*' -r >/dev/null 2>&1
find m -type f | wc -l
echo '--- libraries holding the refused shaders'
grep -r -l -a -E 'pro24MainFragment|lightsMeshFragment' m 2>/dev/null | head
H=m/System/Library/PrivateFrameworks/HelloPoster.framework
ls -la $H/default.metallib | cut -c24-
echo '--- Hello functions'
strings -n 4 $H/default.metallib | grep -E '^[A-Za-z_][A-Za-z0-9_]{3,}$' | grep -i -E 'frag|vert|kernel|compute|main|hello|stroke|mesh' | sort -u | head -40
echo '--- Hello binary files'; find $H -type f | head;
echo '--- Metal use in the Hello binaries'
for f in $(find $H -type f ! -name '*.metallib' | head -8); do strings -n 6 "$f" | grep -E 'MTL|Metal|Fragment|Vertex|functionConstant|CAMetalLayer|CAMesh|Mesh|FunctionConstant' | sort -u | head -30; done
echo '--- function constants in Hello library'
strings -n 3 $H/default.metallib | grep -i -E 'constant|fc_|_FC' | sort -u | head -10
