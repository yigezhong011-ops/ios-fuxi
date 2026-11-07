#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/ci/bridge
LIB=$(find "$D" -name 'libOSMesa.8.dylib' | head -1)
BR=$(find "$D" -name 'libredwood-gl.dylib' | head -1)
echo "=== 桥里的 redwood_gl / EAGL 字符串（子串匹配）==="
for s in redwood_gl_create redwood_gl_make_current redwood_gl_destroy getMacroContextPrivate texImageIOSurface EAGLContext; do
  n=$(strings -a "$BR" | grep -c "$s" || true)
  printf '%-28s %s\n' "$s" "$n"
done
echo
echo "=== libOSMesa 里的 OSMesa 接口字符串 ==="
for s in OSMesaCreateContext OSMesaMakeCurrent OSMesaGetProcAddress; do
  n=$(strings -a "$LIB" | grep -c "$s" || true)
  printf '%-24s %s\n' "$s" "$n"
done
echo
echo "=== 桥导出的符号（_redwood_gl_* 应出现在符号表）==="
strings -a "$BR" | grep -E '^_redwood_gl|^_gl[A-Z]' | head -8
