#!/bin/bash
# Read-only: Metal rejects in the last boot, and how ChronoServices chooses its image type.
L=/root/fuxi/wall1/new.txt
echo "== metal counts"
for p in 'no linear image' 'FunctionConstant' 'function constant' 'pro24MainFragment' 'lightsMeshFragment' 'refused' 'metal2vulkan' 'Vulkan(-' 'unsupported' 'not supported' 'MTLCompiler' 'failed to create' 'pipeline' 'renderPipeline'; do printf '%-26s %s\n' "$p" "$(grep -c -- "$p" $L)"; done
echo "== function constant lines"; grep -n -E 'FunctionConstant|function constant' $L | cut -c1-260 | sort -t: -k2 -u | sort -n | head -20
echo "== metal2vulkan distinct"; grep 'metal2vulkan' $L | sed -E 's/0x[0-9a-f]+/0x/g; s/[0-9]+/N/g' | cut -c1-200 | sort | uniq -c | sort -rn | head -25
echo "== dsc"
D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc; ls $D 2>/dev/null | head -8
sed -n 1,25p /mnt/e/DSH-Fuxi/dump/wsl/run-dsc-glue.sh | cut -c1-140
