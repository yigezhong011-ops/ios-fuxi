#!/bin/bash
# Take out the two calls to 69efcdc's shared cache helpers (a feature we do not need), then list every identifier the port adds that nothing at the pin knows.
set -uo pipefail
cd /root/fuxi/plugin-try
python3 -I - <<'EOF'
p = 'NativeBridgeMetalFrontend.mm'; t = open(p).read()
a = '  const std::string shared=sharedShaderCacheDirectory();\n  NSString *caches=shared.empty()?NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject:@(shared.c_str());\n'
b = '  NSString *caches=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject;\n'
assert t.count(a) == 1; t = t.replace(a, b)
c = ' if(cache && *cache)configureShaderDiskCache(cache);\n'
assert t.count(c) == 1; t = t.replace(c, '')
open(p, 'w').write(t)
EOF
git add -A; git -c user.name=fuxi -c user.email=fuxi@example.invalid commit -q -m "frontend: leave out the shared shader cache helpers of 69efcdc"
git log --oneline -1 | cut -c1-80
grep -n -E 'SharedShaderCache|sharedShader' -r . --include='*.mm' --include='*.h' --include='*.cpp' | cut -c1-120 | head
echo "== identifiers on added lines of source that the pin does not contain"
git diff 7e0d3d2 HEAD -- '*.mm' '*.h' '*.rs' ':!bridge/patches' ':!bridge/interface_regressions_host.mm' | grep -E '^\+[^+]' | sed -E 's://.*$::; s:"[^"]*"::g' | grep -o -E '\b[A-Za-z_][A-Za-z0-9_]{4,}\b' | sort -u > /tmp/added
git grep -h -o -w -E '[A-Za-z_][A-Za-z0-9_]{4,}' 7e0d3d2 -- '*.mm' '*.h' '*.rs' '*.m' | sort -u > /tmp/pin
comm -23 /tmp/added /tmp/pin > /tmp/new; wc -l < /tmp/new
tr '\n' ' ' < /tmp/new | cut -c1-3000; echo
echo "== of those, used in the added source but with no definition-like line"
for s in $(cat /tmp/new); do
  c=$(git grep -c -w -- "$s" HEAD -- NativeBridgeMetalFrontend.mm CacheExport.h 'bridge/NativeMetalObjects.*' | awk -F: '{s+=$NF} END {print s+0}')
  [ "$c" -eq 1 ] && git grep -n -w -- "$s" HEAD -- NativeBridgeMetalFrontend.mm CacheExport.h 'bridge/NativeMetalObjects.*' | cut -c6-170
done | head -50
