#!/bin/bash
# XNU's makefiles ask sw_vers and "sysctl -n hw.*" for host facts. Linux has
# neither in the shape they expect; answer them so the Linux kernel step runs.
set -euo pipefail

CPU=$(nproc 2>/dev/null || echo 4)
MEM=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) * 1024 ))

cat > /usr/bin/sw_vers <<'SH'
#!/bin/sh
case "$1" in
  -productVersion) echo "14.0" ;;
  -buildVersion)   echo "23A344" ;;
  -productName)    echo "macOS" ;;
  *) printf 'ProductName:\tmacOS\nProductVersion:\t14.0\nBuildVersion:\t23A344\n' ;;
esac
SH
chmod +x /usr/bin/sw_vers

# 记录真实的 sysctl，供 shim 转发
if [ -x /usr/sbin/sysctl ] && [ ! -e /usr/bin/sysctl.real ]; then
  ln -sf /usr/sbin/sysctl /usr/bin/sysctl.real
fi

cat > /usr/bin/sysctl <<SH
#!/bin/sh
# answer the hw.* facts XNU asks for, forward everything else
for arg in "\$@"; do
  case "\$arg" in
    hw.memsize)   echo $MEM; exit 0 ;;
    hw.ncpu)      echo $CPU; exit 0 ;;
    hw.logicalcpu) echo $CPU; exit 0 ;;
    hw.physicalcpu) echo $(( $CPU / 2 > 0 ? $CPU / 2 : 1 )); exit 0 ;;
  esac
done
if [ -x /usr/bin/sysctl.real ]; then
  exec /usr/bin/sysctl.real "\$@"
fi
exit 0
SH
chmod +x /usr/bin/sysctl

echo "sw_vers: $(sw_vers -productVersion)  build $(sw_vers -buildVersion)"
echo "sysctl hw.memsize: $(sysctl -n hw.memsize)"
echo "sysctl hw.ncpu:    $(sysctl -n hw.ncpu)"
echo "sysctl hw.logicalcpu: $(sysctl -n hw.logicalcpu)"
echo "sysctl hw.physicalcpu: $(sysctl -n hw.physicalcpu)"
echo "（转发测试）sysctl kernel.ostype: $(sysctl -n kernel.ostype 2>/dev/null || echo n/a)"
