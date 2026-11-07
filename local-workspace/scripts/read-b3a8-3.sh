#!/bin/bash
# Read only: the plugin's framebuffer choice code in both trees, the difference, and how the CI built the branch plugin.
A=/root/fuxi/src-adrenometal; T=ce63701; P=/root/fuxi/plugin-try; OLD=$(git -C $P rev-parse --short HEAD); F=NativeAdrenoMetalPlugin.mm
echo "== $OLD lines 80-128"; git -C $A show $OLD:$F | sed -n 80,128p | cut -c1-210
echo; echo "== diff of the file, first part"; git -C $A diff $OLD $T -- $F | cut -c1-200 | head -110
echo; echo '== places the choice runs, branch'; git -C $A show $T:$F | grep -n -E 'fb-bgra|deep|noDeep|virtualized|CADeviceIsVirtualized|Virtualized|CAEnableDeepFramebuffer|setenv\("CA_|sysctl|iOS 17|21H|__IPHONE|IOS27|TARGET_' | cut -c1-170 | head -40
echo; echo '== build info of the CI plugin'
python3 -I - <<'EOF'
import struct, zlib, json
b = open('/root/fuxi/gpu-plugin-m2v-small/gpuaddon.bin','rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24
def pad8(n): return n + (-n % 8)
for _ in range(c):
    nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
    n = b[at:at+nl-1].decode(); at += pad8(nl); d = b[at:at+pk]; at += pad8(pk)
    if n.endswith('gpu-build.json'): print(zlib.decompress(d).decode()[:1500])
EOF
echo; echo '== boot args of our image'; mtype -i /root/fuxi/t50-gpu7/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -n -iE 'sheng|fb-|args' | cut -c1-260 | head -12
echo; git -C /root/fuxi/unixnu-ci-push show HEAD:.github/workflows/fuxi-gpu.yml | grep -n -iE 'target|ios27|ios17|gpu addon|build-adreno|ipsw|profile|--os|21H|24A' | cut -c1-140 | head -20
