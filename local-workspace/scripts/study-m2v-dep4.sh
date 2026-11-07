#!/bin/bash
# Read-only: the two translator methods in upstream's patch, the bridge's use of them, and which frontend paths reach them.
cd /root/fuxi/src-adrenometal
P=bridge/patches/0025-specialized-links-shared-constants-and-allocation-size.patch
git show de4c1ee:$P > /tmp/0025.patch
grep -n -E '^diff --git|^@@.*(fn |impl )' /tmp/0025.patch | cut -c1-120 | head -40
for s in backing_allocation_size with_specialized_name; do echo "== $s in 0025"; grep -n "$s" /tmp/0025.patch | cut -c1-120; done
N=$(grep -n 'with_specialized_name' /tmp/0025.patch | head -1 | cut -d: -f1); sed -n "$((N-6)),$((N+24))p" /tmp/0025.patch | cut -c1-120
N=$(grep -n 'fn backing_allocation_size' /tmp/0025.patch | head -1 | cut -d: -f1); sed -n "$((N-14)),$((N+18))p" /tmp/0025.patch | cut -c1-120
echo "== bridge"
cd /root/fuxi/plugin-try
grep -n -E 'backing_allocation_size|with_specialized_name' -B8 -A8 bridge/NativeMetalObjects.rs | cut -c1-120
grep -n -E 'allocatedSize|specializedName|SpecializedName|native_metal_function_with_spec|backing_allocation|native_metal_texture_backing' NativeBridgeMetalFrontend.mm bridge/NativeMetalObjects.h | cut -c1-130 | head -20
