#!/bin/bash
# Read only: where the 21H461 shared cache is, the tools to read it, and every way code gets into user processes in this project.
E=/mnt/e/DSH-Fuxi; U=/root/fuxi/up-latest; B=origin/main; V=/root/fuxi/ref-fuxi-v2
echo '== caches and tools'
ls -la $E/ipsw 2>/dev/null | cut -c1-100 | head -12
find /root/fuxi $E/dump $E/tools -maxdepth 3 \( -iname 'dyld_shared_cache*' -o -iname '*.dsc' -o -name 'dscan*' -o -name 'ipsw' \) 2>/dev/null | cut -c1-110 | head -14
which ipsw dyld_info otool llvm-otool llvm-objdump 2>/dev/null
grep -ln 'shared_cache\|dyld_shared\|_UI\|objc' $E/dump/wsl/read-dsc* $E/dump/wsl/*dsc* 2>/dev/null | head -8
sed -n 1,14p $E/dump/wsl/read-dsc-caller-lib.py 2>/dev/null | cut -c1-130
echo; echo '== injection in docs and the fuxi tree'
git -C $U grep -n -iE 'DYLD_INSERT|insert.?librar|libui|inject(s|ed)? .{0,30}(dylib|library|process)|dylib.{0,40}(every|all|each) (process|UI)|text-fixup|text fixup|launchd.{0,30}(env|EnvironmentVariables)' $B -- docs/porting docs/drivers docs/devices/fuxi.md docs/devices/sheng.md docs/devices/asteroids.md ':!docs/zh' | sed "s#^$B:docs/##" | sed 's#https://github.com/[^)]*##g' | cut -c1-300 | head -18
echo; echo '== text-fixup in sources'
git -C $V grep -n -iE 'text-fixup|text_fixup' HEAD -- . | sed 's#^HEAD:##' | cut -c1-190 | head -10
strings -n 8 /root/fuxi/t50-gpu7/kernel.macho | grep -iE 'text-fixup|text_fixup|DYLD_|LIBRARY_PATH' | cut -c1-120 | head -12
echo; echo '== pong init: how the library is inserted'
grep -n -iE 'DYLD|PONG_UI_LIBRARY|setenv|launchd|execve' $E/read/pong-iphone/init.c | cut -c1-170 | head -20
echo; echo '== how our plugin bundle gets loaded, and who'
git -C $V grep -n -iE 'NativeAdrenoMetal.bundle|publish|addons/' HEAD -- 'patches/*' 'scripts/*' 'package/*' | sed 's#^HEAD:##' | cut -c1-190 | head -14
git -C $U grep -n -iE 'NativeAdrenoMetal\.(publish|bundle)|MTLCompilerService|loads? the plugin|plugin.{0,40}(load|dlopen)' $B -- docs/drivers docs/porting ':!docs/zh' | sed "s#^$B:docs/##" | cut -c1-260 | head -10
echo; echo '== overlay in images'
ls -la $E/wallpaper-overlay 2>/dev/null | cut -c1-90 | head -10
grep -ln 'wallpaper-overlay\|overlay' $E/dump/wsl/make-*.sh 2>/dev/null | head -6
