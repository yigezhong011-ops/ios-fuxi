#!/bin/bash
# Read-only: who the sandbox refuses the GPU client, and who gets the Vulkan refusal, across the saved log scans.
set -u
cd /mnt/e/DSH-Fuxi/logs || exit 1
for f in carve-iphonex-first/lscan.txt carve-iphonex-second/lscan.txt; do
  echo "== $f"
  echo '-- sandbox refused GPU client, per process'
  grep -a -oE 'Sandbox: [A-Za-z0-9_.-]+\([0-9]+\) deny\(1\) iokit-open-user-client AGXDeviceUserClient' "$f" | sed -E 's/Sandbox: ([^(]+).*/\1/' | sort | uniq -c | sort -rn | head -24
  echo '-- all iokit denials naming a poster, classes'
  grep -a -oE 'Sandbox: [A-Za-z0-9_.-]*Poster[A-Za-z0-9_.-]*\([0-9]+\) deny\(1\) iokit-[a-z-]+ [A-Za-z0-9_]+' "$f" | sed -E 's/Sandbox: ([^(]+)\([0-9]+\) deny\(1\) /\1 /' | sort | uniq -c | sort -rn | head -24
  echo '-- lines before each Vulkan refusal (nearest process-like text)'
  grep -a -c 'device refused' "$f"
  grep -a -n -B6 'device refused' "$f" | grep -a -E 'Poster|Sandbox|deny|AGX|IOUC|Fig|MetalIntercept' | cut -c1-120 | head -14
done
echo '== latest gpu clients rows'
grep -a -h -oE '\[gpu clients\].{0,330}' carve-iphonex-second/lscan.txt | tail -3
grep -a -h -oE '\[gpu mount.{0,100}|\[gpu windows\].{0,240}' carve-iphonex-second/lscan.txt read-wallsettings3.txt | tail -3
