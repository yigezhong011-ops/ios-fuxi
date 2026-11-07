#!/bin/bash
# Read-only for the phone and working trees: shallow copy of upstream's docs and what they say about our symptoms; args and strings of the t50 kernel.
cd /root/fuxi
if [ ! -d up-latest/.git ]; then git clone -q --depth 1 https://github.com/UniXNU/UniXNU.git up-latest || echo clone failed; fi
git -C up-latest log -1 --format='%h %cd %s' --date=iso | cut -c1-120
D=up-latest/docs
echo "== hvc1/CMPhoto"; grep -rIn -i -E 'hvc1|CMPhoto|12782|HEVC|chronod|ChronoServices|unableToFinalize' $D up-latest/package 2>/dev/null --exclude-dir=zh | cut -c1-520 | head -16
echo "== poster data store"; grep -rIn -i -E 'PRBPoster|dataStore|data store|PosterBoard|PBFPoster' $D --exclude-dir=zh 2>/dev/null | cut -c1-560 | head -24
echo "== clock"; grep -rIn -i -E 'unixnu-rtc|QcomPmicRtc|wrong clock|1970|1969' $D --exclude-dir=zh 2>/dev/null | cut -c1-420 | head -10
echo "== refresh"; grep -rIn -E 'sheng-vsync|vsync=|refresh rate|maximumFramesPerSecond|CADisplay|DCP.*rate|panel-rate|120 Hz' $D up-latest/package --exclude-dir=zh 2>/dev/null | cut -c1-420 | head -24
echo "== t50 args"; cd /root/fuxi/gpu-new-t50-mine; mtype -i vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | cut -c1-500 | head -40
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho /root/fuxi/t50-kernel.look 2>/dev/null
ls -la /root/fuxi/t50-kernel.look | cut -c1-80
echo "== t50 kernel strings"; strings -a /root/fuxi/t50-kernel.look | grep -E '^(sheng|fuxi|unixnu)-[a-z0-9-]+$|-vsync|vsync|[Rr]efresh|[0-9]+ ?Hz|timing|panel' | sort -u | cut -c1-110 | head -80
