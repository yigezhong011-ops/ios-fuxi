#!/bin/bash
# The stock apps on the volume, then the dyld shared cache and the assertion's strings. The image is only read.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
W=/mnt/e/DSH-Fuxi/dump/root-peek
echo "== stock apps asked about"
for a in Health Fitness FitnessCoaching Weather Bridge Watch SiriViewService Siri AssistantServices; do
  n=$(awk '{print $NF}' "$W/list.txt" | grep -c -E "(^|/)Applications/$a\.app$")
  m=$(awk '{print $NF}' "$W/list.txt" | grep -c -E "(^|/)$a\.app$")
  echo "$a Applications=$n anywhere=$m"
done
awk '{print $NF}' "$W/list.txt" | grep -E '\.app$' | grep -i -E 'health|fitness|weather|bridge|siri|assistant|watch|nano' | cut -c1-90 | head -24
echo "== cache files"
grep -E 'dyld_shared_cache_arm64' "$W/list.txt" | awk '{print $4, $NF}' | cut -c1-120 | head -40
grep -E 'dyld_shared_cache_arm64' "$W/list.txt" | awk '{s+=$4} END {print s/1048576 " MiB"}'
grep -E 'PrivateFrameworks/[A-Za-z]*(Poster|PaperBoard)[A-Za-z]*\.framework$' "$W/list.txt" | awk '{print $NF}' | cut -c1-110 | head -20
