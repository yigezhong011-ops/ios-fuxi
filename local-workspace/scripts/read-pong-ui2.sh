#!/bin/bash
# Read only: did pong's status bar work on the phone, how the adapter gets into processes, and what it does for the keyboard. Also how our addon could load one.
P=/mnt/e/DSH-Fuxi/read/pong-iphone; U=/root/fuxi/up-latest; B=origin/main
sed -n 296,330p $P/ui_compat18.c | cut -c1-140
echo; echo '== keyboard and input idiom in the adapter'
grep -n -iE 'InputUI|idiom|UIKeyboard|keyplane|TextInput|UIKBTree|layout|ControlCenter|userInterfaceIdiom' $P/ui_compat18.c | cut -c1-170 | head -24
echo; echo '== loading'; sed -n 855,880p $P/build-ipados18.py | cut -c1-150
grep -n -iE 'DYLD_INSERT|insert_libraries|libpong|ui18|PongUI|compat18' $P/build-ipados18.py $P/init.c $P/profile.toml | cut -c1-180 | head -14
echo; echo '== status bar results on the phone'
sed -n '725,735p;765,772p;790,797p' $P/services.md | cut -c1-280
grep -n -E '状态栏' $P/services.md | tail -12 | cut -c1-280
echo; echo '== pong record: status bar and keyboard device results'
git -C $U show $B:docs/devices/pong.md | grep -n -iE '(status ?bar|状态栏|keyboard|键盘).{0,120}(device|用户|确认|works|shown|显示|正常|通过)' | sed 's#https://github.com/[^)]*##g' | cut -c1-360 | head -10
echo; echo '== what loads into every UI process in our image'
grep -rn -E 'DYLD_INSERT|insert_libraries|LaunchDaemon|launchd.*plist' /mnt/e/DSH-Fuxi/dump/wsl/*.md 2>/dev/null | cut -c1-170 | head -8
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/list-addon.py /root/fuxi/gpu-plugin-1105/gpuaddon.bin 2>/dev/null | cut -c1-90 | head -14
git -C /root/fuxi/ref-fuxi-v2 grep -n -iE 'DYLD_INSERT|libui|ui_compat|addon.*dylib' HEAD -- board.toml AGENTS.md README.md | cut -c1-170 | head -8
git -C $U grep -n -E 'DYLD_INSERT_LIBRARIES|dyld_insert' $B -- docs/porting ':!docs/zh' | sed "s#^$B:docs/##" | cut -c1-240 | head -8
