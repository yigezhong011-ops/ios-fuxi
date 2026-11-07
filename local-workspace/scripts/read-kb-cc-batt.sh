#!/bin/bash
# Read only: the lines behind the keyboard, status bar and battery leads, and what our kernel has for the battery.
U=/root/fuxi/up-latest; B=origin/main; K=/root/fuxi/t50-gpu7/kernel.macho
d() { git -C $U show $B:docs/devices/$1 | sed -n "$2" | sed 's#https://github.com/[^)]*##g' | cut -c1-${3:-900}; }
echo '== ref-fuxi-v2 board.toml 218-236'; sed -n 218,236p /root/fuxi/ref-fuxi-v2/board.toml | cut -c1-260
echo; echo '== mondrian status bar'; git -C $U show $B:docs/devices/mondrian-mzyxsl.md | grep -n -iE 'StatusBar|VisualProvider|Split1080|PongStatus|control center|keyboard' | cut -c1-500 | head -10
echo; echo '== pong: everything on status bar, keyboard layout and resources'
git -C $U show $B:docs/devices/pong.md | grep -n -iE 'StatusBar|VisualProvider|keyboard|TextInput|kbd|phone resources|control center|1080' | sed 's#https://github.com/[^)]*##g' | cut -c1-560 | head -22
echo; echo '== local reading of pong'; ls /mnt/e/DSH-Fuxi/read/pong-iphone/ 2>/dev/null | head -30
grep -rn -iE 'StatusBar|VisualProvider|keyboard|TextInput|kbd|ControlCenter|control center|PhoneResources|\.artwork|bundle' /mnt/e/DSH-Fuxi/read/pong-iphone/ 2>/dev/null | sed 's#/mnt/e/DSH-Fuxi/read/pong-iphone/##' | cut -c1-420 | head -30
echo; echo '== fuxi.md battery section'; d fuxi.md '540,572p' 420
echo; echo '== our kernel: ADSP and battery'
llvm-nm --defined-only $K 2>/dev/null | grep -iE 'batt|adsp|glink|sheng_power|charger|fuel|ipc_?router|PowerSource' | grep -v IOPMPowerSource | cut -d' ' -f3 | cut -c1-70 | head -30
strings -n 6 $K | grep -E '\[battery|\[charger|sheng-battery|sheng-adsp|SWEET BATTERY|Battery' | cut -c1-110 | head -14
echo; echo '== our args'; mtype -i /root/fuxi/t50-gpu7/vol.img ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -oE '(sheng|sweet|offline)-[a-z-]*(batt|adsp|power)[a-z-]*(=[^ "]*)?' | sort -u
echo; echo '== files of the fuxi source trees'; git -C /root/fuxi/ref-fuxi-v2 ls-files | grep -iE 'batt|adsp|glink|ipc|charg' | cut -c1-80 | head -14
