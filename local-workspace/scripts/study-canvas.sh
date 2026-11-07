#!/bin/bash
# Could we do the 1179x2556 canvas ourselves? Where the size is reported, checked and copied. Read-only.
A=/root/fuxi/src-adrenometal; U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150
echo "== files"; git -C $U grep -l -E 'validateSwap|verify_swap' $R -- . | sed "s/^$R://" | head
git -C $U ls-tree -r --name-only $R | grep -i -E 'NativeLegacyDisplay|GOPPresenter|GOPWire|legacy-display' | head -12
echo "== GpuScanoutPresenter.h"; git -C $A show $P:GpuScanoutPresenter.h | sed -n 1,60p | cut -c1-200
git -C $A show $P:GpuScanoutPresenter.h | wc -l
git -C $A show $P:GpuScanoutPresenter.h | grep -n -E 'width|height|Blit|blit|Copy|copy|extent|stride|Extent' | cut -c1-170 | head -40
echo "== who calls it"; git -C $A grep -n -E 'GpuScanoutPresenter|scanoutPresent|presentScanout' $P | sed "s/^$P://" | cut -c1-170 | head -12
echo "== sirius"; git -C $U log origin/main --format='%h %cI %s' -i --grep='sirius' | cut -c1-120 | head -8
echo "== kernel symbols t50"; python3 - <<'EOF'
import subprocess
out = subprocess.run(['strings', '-a', '/root/fuxi/t50-mine/kernel.macho'], capture_output=True, text=True).stdout.splitlines()
hits = sorted({l[:150] for l in out if any(k in l for k in ('validateSwap', 'validate_swap', 'verify_swap', 'NativeLegacyDisplay::', 'NativeGOP', 'scanout'))})
print(len(hits))
print('\n'.join(hits[:40]))
EOF
which llvm-nm nm 2>/dev/null | head -2
ls /root/fuxi/*.py 2>/dev/null | head -3
ls /mnt/e/DSH-Fuxi/dump/wsl | grep -i -E 'canvas|disasm|symbols|nm-' | head
sed -n 1,30p /mnt/e/DSH-Fuxi/dump/wsl/patch-canvas.py | cut -c1-170
echo "== cave on t50"; bash /root/fuxi/crst.sh 41773883659 | sed -n 1p
