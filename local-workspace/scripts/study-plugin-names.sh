#!/bin/bash
# Read-only: the suspicious names in the ported frontend.
cd /root/fuxi/plugin-try
grep -n -E 'configureShaderDiskCache|sharedShaderCacheDirectory|NSSearchPathForDirectoriesInDomains' NativeBridgeMetalFrontend.mm *.h 2>/dev/null | cut -c1-220
N=$(grep -n 'configureShaderDiskCache' NativeBridgeMetalFrontend.mm | head -1 | cut -d: -f1); [ -n "$N" ] && sed -n "$((N-6)),$((N+22))p" NativeBridgeMetalFrontend.mm | cut -c1-170
echo "== in the patch: how many times and sign"
git diff 7e0d3d2 HEAD -- NativeBridgeMetalFrontend.mm | grep -n -E '^[-+ ].*(configureShaderDiskCache|sharedShaderCacheDirectory)' | cut -c1-170
echo "== other uses of names the diff adds and the bridge must export"
grep -n -E 'nmb_[a-z_]*shader_cache|shader_cache_directory' NativeBridgeMetalFrontend.mm bridge/NativeMetalObjects.h bridge/*.rs | cut -c1-150 | head -10
