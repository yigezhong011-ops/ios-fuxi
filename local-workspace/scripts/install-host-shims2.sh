#!/bin/bash
set -euo pipefail
CPU=$(nproc 2>/dev/null || echo 4)
MEM=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) * 1024 ))

install -d /usr/local/bin

cat > /usr/local/bin/sw_vers <<'SH'
#!/bin/sh
case "$1" in
  -productVersion) echo "14.0" ;;
  -buildVersion)   echo "23A344" ;;
  -productName)    echo "macOS" ;;
  *) printf 'ProductName:\tmacOS\nProductVersion:\t14.0\nBuildVersion:\t23A344\n' ;;
esac
SH
chmod 755 /usr/local/bin/sw_vers

cat > /usr/local/bin/sysctl <<SH
#!/bin/sh
for arg in "\$@"; do
  case "\$arg" in
    hw.memsize)     echo $MEM; exit 0 ;;
    hw.ncpu)        echo $CPU; exit 0 ;;
    hw.logicalcpu)  echo $CPU; exit 0 ;;
    hw.physicalcpu) echo $(( $CPU / 2 > 0 ? $CPU / 2 : 1 )); exit 0 ;;
  esac
done
exec /usr/sbin/sysctl "\$@"
SH
chmod 755 /usr/local/bin/sysctl

echo "PATH = $PATH"
echo "which sysctl -> $(command -v sysctl)"
echo "which sw_vers -> $(command -v sw_vers)"
echo
echo "hw.memsize     = $(sysctl -n hw.memsize)"
echo "hw.ncpu        = $(sysctl -n hw.ncpu)"
echo "hw.logicalcpu  = $(sysctl -n hw.logicalcpu)"
echo "hw.physicalcpu = $(sysctl -n hw.physicalcpu)"
echo "kernel.ostype  = $(sysctl -n kernel.ostype 2>/dev/null || echo n/a)"
echo "sw_vers        = $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
