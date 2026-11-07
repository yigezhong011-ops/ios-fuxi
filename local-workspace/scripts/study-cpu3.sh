K=/root/fuxi/t50-mine/kernel.macho; IMG=/mnt/e/DSH-Fuxi/logs/data-raw.img; A=/mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py
echo "=== kernel bring-up strings"; strings -n 5 $K | grep -E 'came alive|NOT alive|CPU_ON|sheng-smp|cpus_registered|initCPU|SGI1' | cut -c1-130 | sort -u | head -16
echo "=== source"; grep -rIln --exclude-dir=.git -E 'sheng-smp' /root/fuxi-build/UniXNU 2>/dev/null | grep -v '/out/' | head -6
for p in $(grep -rIl --exclude-dir=.git -E 'sheng-smp' /root/fuxi-build/UniXNU 2>/dev/null | grep -v '/out/' | grep -E '\.(cpp|c|h|patch|toml)$' | head -4); do echo "--- $p"; grep -n -B1 -A3 'sheng-smp' $p | cut -c1-200 | head -18; done
echo "=== ips in Data copy"
for d in /mobile/Library/Logs/CrashReporter /mobile/Library/Logs/CrashReporter/Retired; do python3 -I $A $IMG ls 0 $d 2>/dev/null | awk '{print $NF}' | grep -E '\.ips' | head -12; done
echo "=== raw field scan (first 12)"
timeout 170 grep -a -o -E '"(activeCPUs|ncpu|cpuCount|cpu_count|logicalCPUs|physicalCPUs)"[ :]+[0-9]+|Active cpus: *[0-9]+|hw\.(activecpu|ncpu|logicalcpu)[ :=]+[0-9]+' $IMG | sort | uniq -c | sort -rn | head -12
echo "scan rc=$?"