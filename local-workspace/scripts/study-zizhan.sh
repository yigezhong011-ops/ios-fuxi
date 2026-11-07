#!/bin/bash
# Read-only: upstream's fuxi and zizhan records, full t50 args.
cd /root/fuxi/up-latest/docs/.vitepress/device-records
echo "== t50 args"; mtype -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/unixnu.toml | tr ' ' '\n' | grep -E 'vsync|dpu|fb-|panel|backlight|scanout|gpu|setup|persist' | tr '\n' ' '; echo
echo "== fuxi head"; sed -n 1,30p fuxi.toml | cut -c1-300
echo "== fuxi diff vs sheng"; diff <(sed -n 1,400p sheng.toml) <(sed -n 1,400p fuxi.toml) | grep -E '^>' | cut -c1-300 | head -24
echo "== zizhan"; grep -n -E 'repository|source_repo|url|github|^summary' zizhan.toml | cut -c1-220 | head -12
sed -n 90,125p zizhan.toml | cut -c1-900
grep -n -i -E 'wallpaper|poster|widget|hvc1|Metal|unified|clock' zizhan.toml | cut -c1-500 | head -24
echo "== poster-related in pong/sheng/zizhan"; grep -n -i -E 'wallpaper|poster' pong.toml sheng.toml | cut -c1-500 | head -24
