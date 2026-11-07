#!/bin/bash
# Read only: how pong solves the 1080 wide screen in user space.
P=/mnt/e/DSH-Fuxi/read/pong-iphone; U=/root/fuxi/up-latest; B=origin/main
wc -l $P/ui_compat18.c $P/init.c $P/services.md
sed -n 1,40p $P/ui_compat18.c | cut -c1-170
echo; echo '== names in ui_compat18.c'
grep -n -iE 'StatusBar|VisualProvider|keyboard|keyplane|TextInput|ControlCenter|CC[A-Z]|class_addMethod|objc_allocateClassPair|method_setImplementation|interpose|__attribute__\(\(constructor|screen|393|360|1080|2412|MGCopy|MGGet' $P/ui_compat18.c | cut -c1-165 | head -70
echo; echo '== build script: how it is loaded, resources copied'
grep -n -iE 'ui_compat|DYLD_INSERT|keyboard|TextInput|phone_resources|phone resources|layout|\.keyboard|KeyboardLayout|statusbar' $P/build-ipados18.py $P/init.c $P/profile.toml | cut -c1-210 | head -30
echo; echo '== services.md'
grep -n -iE 'StatusBar|状态栏|keyboard|键盘|控制中心|ControlCenter|TextInput|电池|battery' $P/services.md | cut -c1-330 | head -22
echo; echo '== pong record, keyboard section'
git -C $U show $B:docs/devices/pong.md | sed -n 957,1030p | grep -vE '^\s*$' | sed 's#https://github.com/[^)]*##g' | cut -c1-260 | head -40
echo; echo '== other device records with a phone UI on an unknown size'
git -C $U grep -l -iE 'StatusBarVisualProvider' $B -- docs/devices ':!docs/zh' | sed "s#^$B:docs/devices/##" | head
git -C $U grep -n -iE 'StatusBarVisualProvider' $B -- docs/devices ':!docs/zh' | sed "s#^$B:docs/devices/##" | sed 's#https://github.com/[^)]*##g' | cut -c1-300 | head -8
