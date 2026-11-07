#!/bin/bash
# Read only: Metal and pipeline errors in the capture after Pride went black on the branch plugin.
C=/mnt/e/DSH-Fuxi/logs; N=$C/carve-$1/lscan.txt; wc -l $N
echo '--- Pride process'
grep -a -n -E 'PridePosterExte|PridePoster\b' $N | tail -8 | cut -c1-170
echo '--- errors from Metal paths'
grep -a -E 'MetalView|CAMetalLayer|nextDrawable|MTLCompiler|makeRenderPipeline|Compiler failed|pipeline state|PipelineState|Failed to create|Command buffer|commandBuffer|function constant|functionConstant|\bm2v\b|metal2vulkan|lowering|translat|NativeBridge|NativeAdreno|turnip|Turnip|VK_ERROR|vkCreate|refus' $N | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9]+/N/g' | cut -c1-175 | sort | uniq -c | sort -rn | head -45
echo '--- pro24 and pride shader names'
grep -a -n -E 'pro24|lightsMesh|PrideMetal|\.metallib' $N | tail -12 | cut -c1-175
