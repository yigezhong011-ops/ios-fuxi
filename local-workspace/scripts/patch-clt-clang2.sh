#!/bin/bash
# Refine the CLT clang shim: XNU builds SETUP tools from inside their object
# directory, so the source/output paths carry no "SETUP" component. Detect the
# working directory too, and treat any SETUP invocation (compile or link) as a
# host build.
set -euo pipefail
SHIM=/opt/unixnu-linux/CommandLineTools/usr/bin/clang

cat > "$SHIM" <<'SH'
#!/bin/bash
# Darwin cross clang for the kernel; the host compiler for XNU's SETUP tools.
is_setup=0
case "$PWD" in
  *SETUP*) is_setup=1 ;;
esac
for a in "$@"; do
  case "$a" in
    *SETUP*) is_setup=1 ;;
  esac
done
if [ "$is_setup" = 1 ]; then
  args=()
  skip_next=0
  for a in "$@"; do
    if [ "$skip_next" = 1 ]; then skip_next=0; continue; fi
    case "$a" in
      -target) skip_next=1; continue ;;
      arm64-apple-*|arm64e-apple-*) continue ;;
      -mmacosx-version-min=*) continue ;;
      -mllvm) skip_next=1; continue ;;
      -fptrauth-function-pointer-type-discrimination) continue ;;
      -mno-implicit-sme) continue ;;
    esac
    args+=("$a")
  done
  exec /usr/bin/clang "${args[@]}"
fi
real="${CROSS_CLANG:-/opt/unixnu-linux/llvm/bin/clang}"
drop=(${XNU_CLANG_DROP_FLAGS--mno-implicit-sme})
args=()
for a in "$@"; do
    skip=0
    for d in "${drop[@]}"; do [ "$a" = "$d" ] && skip=1 && break; done
    [ "$skip" = 1 ] || args+=("$a")
done
exec "${real}" -target "${DARWIN_TRIPLE:-arm64e-apple-macos26.0}" \
    ${CROSS_EXTRA_FLAGS--fptrauth-function-pointer-type-discrimination -mllvm -disable-atexit-based-global-dtor-lowering -D__ARM_ARCH_8_2__=1 -D__ARM_ARCH_8_3__=1 -D__ARM_ARCH_8_4__=1 -D__ARM_ARCH_8_5__=1} \
    "${args[@]}"
SH
chmod 755 "$SHIM"

echo "=== 自检 1：SETUP 目录里编译+链接 ==="
rm -rf /tmp/setuptest && mkdir -p /tmp/setuptest/SETUP
printf '#include <stdio.h>\nint main(void){puts("ok");return 0;}\n' > /tmp/setuptest/SETUP/probe.c
cd /tmp/setuptest/SETUP
"$SHIM" -c probe.c -o probe.o 2>&1 | head -2
echo "  目标文件: $(file -b probe.o 2>/dev/null | cut -d, -f1-2)"
"$SHIM" probe.o -o probe 2>&1 | head -3
if [ -x probe ]; then echo "  链接成功: $(./probe)"; else echo "  链接失败"; fi
