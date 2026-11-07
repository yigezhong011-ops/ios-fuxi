cd /root/fuxi/unixnu-pin/docs/zh
echo "=== search"; grep -rIl -i -E 'cluster-type|cluster_type|P 簇|E 簇|sheng-smp|cpu-capacity|大核|性能核' . | head -14
grep -rIn -E 'cluster-type|cluster_type|sheng-smp' . | cut -c1-240 | head -18
echo "=== power 145-170"; sed -n '145,170p' porting/power.md | cut -c1-320
echo "=== drivers"; grep -n -i -E 'smp|cluster|CPU_ON|armcpu|PSCI' porting/drivers.md | cut -c1-240 | head -16
echo "=== dts fuxi vs sheng"; cd /root/fuxi/fuxi2; ls dts | head; grep -n -E 'cluster-type|unixnu,' dts/*.dts* | cut -c1-140 | head -20
sed -n '125,150p' board.toml | cut -c1-200
grep -rIn --exclude-dir=.git -E 'cluster-type|cluster_type' drivers kits package patches scripts 2>/dev/null | cut -c1-200 | head -18