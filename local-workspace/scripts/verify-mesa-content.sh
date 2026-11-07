#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/ci/bridge
LIB=$(find "$D" -name 'libOSMesa.8.dylib' | head -1)
echo "=== libOSMesa 里的驱动 ==="
for s in softpipe freedreno zink swrast a6xx a7xx; do
  n=$(strings -a "$LIB" | grep -c "$s" || true)
  printf '%-10s 出现 %s 次\n' "$s" "$n"
done
echo
echo "=== 关键符号 ==="
for s in OSMesaCreateContext OSMesaMakeCurrent OSMesaGetProcAddress fd_screen_create redwood_gl_create; do
  if strings -a "$LIB" | grep -q "^$s$"; then echo "FOUND $s"; else echo "----- $s"; fi
done
echo
echo "=== 桥里是否有 EAGL 关键符号 ==="
BR=$(find "$D" -name 'libredwood-gl.dylib' | head -1)
for s in EAGLContext getMacroContextPrivate redwood_gl_create texImageIOSurface; do
  if strings -a "$BR" | grep -q "$s"; then echo "FOUND $s"; else echo "----- $s"; fi
done
