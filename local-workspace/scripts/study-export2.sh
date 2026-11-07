#!/bin/bash
# What turns the pipeline-cache export on? Read-only.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150
git -C $A show $P:CacheExport.h | grep -n -E 'start|thread|period|Period|getprogname|sysctl|return;|if ?\(' | cut -c1-170 | head -30
echo "== callers"
git -C $A grep -n -E 'cacheexport::|CacheExport\.h' $P -- '*.mm' '*.h' '*.cpp' | sed "s/^$P://" | cut -c1-190 | head -12
git -C $A show $P:NativeAdrenoMetalPlugin.mm | grep -n -E 'cacheexport|sheng-|sysctl|kern\.bootargs|ngpu/debug' | cut -c1-190 | head -24
echo "== kernel side of method 0x7100"
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'sheng-[a-z-]*(export|cache|diag|trace|oslog)[a-z-]*' | cut -c1-90 | sort -u | head -20
