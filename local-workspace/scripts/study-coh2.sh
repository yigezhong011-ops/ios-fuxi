cd /root/fuxi/fuxi2/kits/sheng
sed -n '1078,1200p' GpuPowerProbe.cpp | cut -c1-190
echo "=== args"; export MTOOLS_SKIP_CHECK=1; mtype -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a '^args' | tr ' ' '\n' | grep -i 'coher\|pause'
echo "=== callers"; grep -n 'coherenceProbe\|gCoherenceAttempts\|coherence_turn' *.cpp | cut -c1-170 | head -12
