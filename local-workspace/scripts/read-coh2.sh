B=/root/build/fuxi/build/sheng-logs; G=$B/untagged-45d8d0fd; F=$B/untagged-20611b89
show(){ awk -v want="$2" '/^#slot /{split($3,a,"="); t=a[2]+0; p=(t==want)} p' $1/slots.txt | grep -a -E '^(#slot|X[2-7] |\[clocks\])' | cut -c1-130; }
for t in 8 10 12; do echo "--- FAIL t=$t"; show $F ${t}s 2>/dev/null; done
for t in 10 12 14 16 18 22 28; do echo "--- GOOD t=$t"; show $G $t; done
echo "=== fail slot times"; grep -a '^#slot ' $F/slots.txt | cut -c1-30 | tr '\n' ';'
echo; echo "=== X row source"; cd /root/fuxi/fuxi2/kits/sheng; grep -n -E '"S zap|zap' GpuPowerProbe.cpp | cut -c1-200 | head -24
echo "=== good msgbuf after launchd"; grep -a -n -E 'zap|gmu|GMU|firmware|scm|tz|a740' $F/msgbuf.txt | cut -c1-150 | tail -10