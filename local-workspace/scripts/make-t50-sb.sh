#!/bin/bash
# A gesture test image from t50-gpu7 (old plugin, longer grant, f9) with the status bar library. Temp boot only.
# Usage: [AUTO_CORES=0xf9] make-t50-sb.sh <out name>
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
OUT=$1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=${BASE:-/root/fuxi/t50-gpu7}; W=/root/fuxi/plug-$OUT
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp "$B/vol.img" vol.img; cp "$B/kernel.macho" kernel.macho
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > addon-cur.bin
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > trust-cur.bin
# Stubs: the symbols it takes, in the two libraries the plugin already links.
stub() { # name, install name, symbols
  { echo '--- !tapi-tbd'; echo 'tbd-version: 4'; echo 'targets: [ arm64-ios ]'; echo "install-name: '$2'"; echo 'current-version: 1'; echo 'exports:'; echo '  - targets: [ arm64-ios ]'; echo "    symbols: [ $3 ]"; echo '...'; } > "$1"
}
stub libobjc.tbd /usr/lib/libobjc.A.dylib '_objc_lookUpClass, _objc_allocateClassPair, _object_getClass, _objc_registerClassPair, _objc_msgSend, _sel_registerName, _class_addMethod, _class_getInstanceVariable, _class_getInstanceMethod, _class_getClassMethod,_method_getImplementation, _method_setImplementation, _method_getTypeEncoding, _object_getIvar, _object_setIvarWithStrongDefault'
stub libSystem.tbd /usr/lib/libSystem.B.dylib '_dlsym, _getprogname, _strcmp, _syslog, _mach_task_self_, _vm_read_overwrite, _vm_write, __dispatch_main_q, _dispatch_time, _dispatch_async_f, _dispatch_after_f'
tr -d '\r' < $S/fuxi-statusbar.c > fuxi-statusbar.c
clang -target arm64-apple-ios17.0 -Os -nostdinc -fno-stack-protector -fno-builtin -Wall -Wno-unused-parameter -c fuxi-statusbar.c -o fuxi-statusbar.o
ld64.lld -dylib -arch arm64 -platform_version ios 17.0 17.0 -install_name @loader_path/FuxiStatusBar.dylib -fixup_chains -adhoc_codesign \
  -o FuxiStatusBar.dylib fuxi-statusbar.o libobjc.tbd libSystem.tbd
llvm-nm -u FuxiStatusBar.dylib | wc -l
llvm-otool -l FuxiStatusBar.dylib | grep -E 'cmd LC_(LOAD_DYLIB|CODE_SIGNATURE|DYLD_CHAINED|ID_DYLIB)' | sort | uniq -c
tr -d '\r' < $S/add-statusbar-dylib.py > add.py
python3 -I add.py addon-cur.bin FuxiStatusBar.dylib addon-merged.bin cdhashes.txt
python3 -I $S/fit-addon.py addon-cur.bin addon-merged.bin addon-fitted.bin
[ "$(stat -c %s addon-fitted.bin)" = "$(stat -c %s addon-cur.bin)" ]
tr -d '\r' < $S/grow-trustcache.py > grow.py
python3 -I grow.py trust-cur.bin cdhashes.txt trust-new.bin
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-fitted.bin >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache trust-new.bin --grow
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-fitted.bin
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache | cmp - trust-new.bin
tr -d '\r' < $S/make-t50-grant.sh > /tmp/make-t50-grant-$OUT.sh
bash /tmp/make-t50-grant-$OUT.sh "$W" "$OUT"
ls -la $E/$OUT.img; sha256sum $E/$OUT.img | cut -c1-16
