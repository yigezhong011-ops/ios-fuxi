#!/bin/bash
# List the sheng-gpu / cpufreq / vsync boot arguments a kernel knows (string table scan).
K=${1:-/root/fuxi/t32/kernel.macho}
grep -a -o -E 'sheng-gpu-[a-z-]+|sheng-cpufreq[a-z-]*|sheng-vsync[a-z-]*|sheng-fb-[a-z-]+|sheng-dpu[a-z-]*' "$K" | sort -u | tr '\n' ' '
echo
