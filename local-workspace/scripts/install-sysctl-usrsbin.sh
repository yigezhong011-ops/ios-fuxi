#!/bin/bash
# XNU's Makefile calls /usr/sbin/sysctl by absolute path, so put the shim there
# and keep the real procps binary for everything else.
set -euo pipefail
CPU=$(nproc 2>/dev/null || echo 4)
MEM=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) * 1024 ))

REAL=/usr/sbin/sysctl.procps
if [ ! -e "$REAL" ]; then
  cp -a /usr/sbin/sysctl "$REAL"
  echo "已备份真实 sysctl -> $REAL"
fi

cat > /usr/sbin/sysctl <<SH
#!/bin/sh
for arg in "\$@"; do
  case "\$arg" in
    hw.memsize)     echo $MEM; exit 0 ;;
    hw.ncpu)        echo $CPU; exit 0 ;;
    hw.logicalcpu)  echo $CPU; exit 0 ;;
    hw.physicalcpu) echo $(( $CPU / 2 > 0 ? $CPU / 2 : 1 )); exit 0 ;;
  esac
done
exec $REAL "\$@"
SH
chmod 755 /usr/sbin/sysctl

echo "验证（绝对路径调用）:"
/usr/sbin/sysctl -n hw.physicalcpu
/usr/sbin/sysctl -n hw.logicalcpu
/usr/sbin/sysctl -n hw.memsize
echo "转发验证: /usr/sbin/sysctl -n kernel.ostype -> $(/usr/sbin/sysctl -n kernel.ostype 2>/dev/null || echo n/a)"
