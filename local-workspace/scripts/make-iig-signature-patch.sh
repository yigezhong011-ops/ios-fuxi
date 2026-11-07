#!/bin/bash
# The iig stand-in emits LOCAL methods into X_Methods, which adds an
# OSDispatchMethod parameter; the definitions UniXNU wrote for it omit that
# parameter, so out-of-line definitions do not match. Add the parameter.
set -uo pipefail
T=/root/fuxi/fork-device/patches/xnu
W=/tmp/wifi-patch
mkdir -p "$W"
F=/root/ux2/fuxi/tree/.cache/xnu-work/iokit/Kernel/IOUserServer.cpp
cp "$F" "$W/IOUserServer.cpp.orig"

python3 - "$W/IOUserServer.cpp.orig" "$W/IOUserServer.cpp.new" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
t = open(src).read()
a = """kern_return_t
IOService::UserSetProperties(OSContainer * properties)
{
	return UserSetProperties_Impl(properties);
}"""
b = """kern_return_t
IOService::UserSetProperties(OSContainer * properties, OSDispatchMethod supermethod)
{
	(void)supermethod;
	return UserSetProperties_Impl(properties);
}"""
c = """kern_return_t
IOService::SendIOMessageServicePropertyChange(void)"""
d = """kern_return_t
IOService::SendIOMessageServicePropertyChange(OSDispatchMethod supermethod)"""
if a not in t or c not in t:
    sys.exit('找不到要改的定义')
t = t.replace(a, b, 1).replace(c, d, 1)
open(dst, 'w').write(t)
print('已改两处定义')
PY

cd "$W"
diff -u IOUserServer.cpp.orig IOUserServer.cpp.new > "$T/portable-iig-local-methods.patch" || true
head -3 "$T/portable-iig-local-methods.patch"
echo "补丁大小: $(wc -l < "$T/portable-iig-local-methods.patch") 行"
cd /root/fuxi/fork-device
git -c user.name=dsh -c user.email=dsh@local add -A patches/xnu
git -c user.name=dsh -c user.email=dsh@local commit -q -m "patches: match the iig shim's LOCAL method signatures" 2>/dev/null || true
git push -q origin old 2>/dev/null && echo "已推送" || true
