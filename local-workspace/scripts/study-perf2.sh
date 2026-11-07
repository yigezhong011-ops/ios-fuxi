cd /root/fuxi
echo "=== done row source"; grep -rIln --exclude-dir=.git -E 'swap timeline' src-adreno740 unixnu-pin/drivers /root/build/unixnu/drivers fuxi2 2>/dev/null | head -5
grep -rIn --exclude-dir=.git -E 'offer=|done=' /root/build/unixnu/drivers/GopFramebuffer unixnu-pin/drivers/GopFramebuffer 2>/dev/null | cut -c1-240 | head -6
echo "=== gpu freq in src-adreno740"; grep -rIn --exclude-dir=.git -i 'dcvs\|perf_table\|gx_table\|freq\|MHz\|bw_vote\|bimc\|\bddr\b' src-adreno740 2>/dev/null | grep -v '^.*\.md:.*test' | cut -c1-200 | head -35
echo "=== docs power (sheng)"; grep -n -i 'freq\|dcvs\|cpufreq\|频率\|GHz\|MHz' unixnu-pin/docs/zh/porting/power.md | cut -c1-230 | head -20
grep -n -i 'freq\|频率\|GHz\|MHz\|fps\|帧' unixnu-pin/docs/zh/devices/sheng.md | cut -c1-230 | head -30
echo "=== boot arg"; grep -n -i 'freq\|cpu\|gpu' unixnu-pin/docs/zh/xnu/boot-arguments.md | cut -c1-200 | head -25
echo "=== adreno740 doc"; grep -n -i 'freq\|频率\|MHz\|性能\|fps\|DCVS\|GMU' unixnu-pin/docs/zh/drivers/adreno740.md | cut -c1-230 | head -25
echo "=== current args"; export MTOOLS_SKIP_CHECK=1; mtype -i /root/fuxi/auto-t50-auto-120fix-p/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a '^args' | tr ' ' '\n' | grep -i 'gpu\|freq\|cpu\|pause\|fb-' 