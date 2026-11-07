cd /root/fuxi/unixnu-pin/docs/zh
echo "=== zap in docs"; grep -rIn -i -E 'zap|sheng-gpu-zap' drivers/adreno740.md porting/gpu.md devices/sheng.md xnu/boot-arguments.md guide/debugging.md 2>/dev/null | cut -c1-300 | head -24
echo "=== en sheng: zap / hang / warm reset"; cd ../; grep -n -i -E 'zap|warm|cold boot|after a reboot|reboot.*(hang|fail)|hang.*(reboot|boot)|watchdog|second boot|hard reset|power.?cycle' devices/sheng.md | cut -c1-320 | head -30
echo "=== fuxi repo docs"; cd /root/fuxi/fuxi2; ls docs 2>/dev/null | head; grep -rIln -i -E 'zap' README.md docs 2>/dev/null | head
echo "=== zapAndSecure source"; sed -n '572,660p' kits/sheng/GpuPowerProbe.cpp | cut -c1-175