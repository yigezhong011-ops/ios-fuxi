#!/bin/bash
# The CLT clang shim forces the Darwin/iOS target on everything, but XNU's SETUP
# tools are host programs. Recognise SETUP sources and hand those to the host
# compiler without the cross target. A backup of the original shim is kept.
set -euo pipefail
SHIM=/opt/unixnu-linux/CommandLineTools/usr/bin/clang
[ -f "$SHIM" ] || { echo "找不到 $SHIM"; exit 1; }

if [ ! -e "$SHIM.orig" ]; then
  cp -a "$SHIM" "$SHIM.orig"
  echo "已备份原 shim -> $SHIM.orig"
fi

cat > "$SHIM" <<'SH'
#!/bin/bash
# Darwin cross clang for the kernel; host clang for XNU's SETUP tools.
for a in "$@"; do
  case "$a" in
    */SETUP/*|SETUP/*)
      exec /usr/bin/clang -Wno-unused-command-line-argument \
        $(printf '%s\n' "$@" | grep -v '^-target$' | grep -v '^arm64' | grep -v '^-mmacosx-version-min=') 2>/dev/null
      ;;
  esac
done
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
echo "shim 已更新：SETUP 源码走主机 clang"
echo "--- 自检：SETUP 源应编出 x86/ELF ---"
mkdir -p /tmp/setuptest && cd /tmp/setuptest
printf '#include <stdio.h>\nint main(void){puts("ok");return 0;}\n' > SETUP/probe.c 2>/dev/null || { mkdir -p SETUP; printf '#include <stdio.h>\nint main(void){puts("ok");return 0;}\n' > SETUP/probe.c; }
"$SHIM" -c SETUP/probe.c -o probe.o 2>&1 | head -3
file probe.o 2>/dev/null | head -1
