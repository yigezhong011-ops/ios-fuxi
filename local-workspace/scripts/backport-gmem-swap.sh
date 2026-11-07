#!/bin/bash
# Backport turnip-gmem-memory-side-swap onto the Mesa patch set pinned at UniXNU 793d6bddf7, into E:\DSH-Fuxi\ci\patches.
# Touches no image and pushes nothing.
set -uo pipefail
U=/root/fuxi/src-unixnu; M=/root/fuxi/src-mesa-pin; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
OUT=/mnt/e/DSH-Fuxi/ci/patches; mkdir -p "$OUT"
git -C "$M" reset -q --hard; git -C "$M" clean -qfd
git -C "$U" show $R:scripts/data/adreno-compiler-inputs.json > /tmp/pins.json
for p in $(python3 -c 'import json; print(" ".join(json.load(open("/tmp/pins.json"))["patches"]))'); do
  git -C "$U" show $R:$p | git -C "$M" apply - || { echo "BAD $p"; exit 1; }
done
cd "$M"; git add -A; git -c user.name=x -c user.email=x@x commit -q -m pinned
F=src/freedreno/vulkan/tu_clear_blit.cc
echo "== pinned r3d_src_gmem_load"; grep -n -A8 'r3d_src_gmem_load' $F | head -24 | cut -c1-140
python3 - <<'EOF'
import subprocess
p = '/root/fuxi/src-mesa-pin/src/freedreno/vulkan/tu_clear_blit.cc'
s = open(p).read()
helper_anchor = 'template <chip CHIP>\nstatic void\nr2d_dst_impl('
assert s.count(helper_anchor) == 1
s = s.replace(helper_anchor, '''/* The memory side of a transfer between tile memory and a linear image keeps the image's own swap. Backport of upstream
 * turnip-gmem-memory-side-swap: with the identity swap on the memory side a GMEM pass stored drawn BGRA8 colour with red and blue
 * exchanged and loaded memory into tile memory in memory order. The tile side stays the identity. */
static inline uint32_t
tu_gmem_memory_side_info(uint32_t info)
{
   return info;
}

''' + helper_anchor)
a = '''      dst_info = tu_gmem_transfer_swap_fixup(dst_info, A6XX_RB_A2D_DEST_BUFFER_INFO_COLOR_SWAP__MASK,
                                             A6XX_RB_A2D_DEST_BUFFER_INFO_COLOR_SWAP(WZYX), iview->is_mutable);'''
assert s.count(a) == 1
s = s.replace(a, '      dst_info = tu_gmem_memory_side_info(dst_info);')
b = '''      mrt_buf_info = tu_gmem_transfer_swap_fixup(mrt_buf_info, A6XX_RB_MRT_BUF_INFO_COLOR_SWAP__MASK,
                                                 A6XX_RB_MRT_BUF_INFO_COLOR_SWAP(WZYX), iview->is_mutable);'''
assert s.count(b) == 1
s = s.replace(b, '      mrt_buf_info = tu_gmem_memory_side_info(mrt_buf_info);')
c = '''      tu_cs_emit(cs, gmem_transfer ?
                        tu_gmem_transfer_swap_fixup(blt_view->view->RB_RESOLVE_SYSTEM_BUFFER_INFO,
                                                    A6XX_RB_RESOLVE_SYSTEM_BUFFER_INFO_COLOR_SWAP__MASK,
                                                    A6XX_RB_RESOLVE_SYSTEM_BUFFER_INFO_COLOR_SWAP(WZYX),
                                                    blt_view->view->is_mutable) :
                        blt_view->view->RB_RESOLVE_SYSTEM_BUFFER_INFO);'''
assert s.count(c) == 1
s = s.replace(c, '''      tu_cs_emit(cs, gmem_transfer ? tu_gmem_memory_side_info(blt_view->view->RB_RESOLVE_SYSTEM_BUFFER_INFO) :
                                     blt_view->view->RB_RESOLVE_SYSTEM_BUFFER_INFO);''')
d = '   r3d_src_load<CHIP>(cmd, cs, iview, layer, VK_FILTER_NEAREST, true);'
print('r3d_src_load sites', s.count(d))
assert s.count(d) == 1
s = s.replace(d, '   /* The memory side keeps the image\'s own swap (tu_gmem_memory_side_info); a mutable view\'s stays as upstream. */\n'
              '   r3d_src_load<CHIP>(cmd, cs, iview, layer, VK_FILTER_NEAREST, iview->view.is_mutable);')
open(p, 'w').write(s)
EOF
[ $? = 0 ] || exit 1
git diff --stat
git diff > "$OUT/turnip-gmem-memory-side-swap-793d.patch"
wc -l "$OUT/turnip-gmem-memory-side-swap-793d.patch"
echo "== remaining users of the old fixup"; grep -n 'tu_gmem_transfer_swap_fixup' $F | cut -c1-150
echo "== is_mutable member, helper use"; grep -n 'r3d_src_load' $F | cut -c1-120 | head; grep -n 'is_mutable' src/freedreno/vulkan/tu_image.h src/freedreno/fdl/freedreno_layout.h | cut -c1-120
echo "== recheck apply from clean"
git checkout -q -- .; git apply --check "$OUT/turnip-gmem-memory-side-swap-793d.patch" && echo APPLY-OK
git -C /root/fuxi/src-mesa-pin reset -q --hard HEAD~1; git clean -qfd
echo "== prime list handling at 793d"
git -C "$U" show $R:scripts/build-adreno-metal-plugin.py | grep -n -E 'prime-list|primelist' | cut -c1-170
git -C "$U" show $R:scripts/make-gpu-addon.py | sed -n 55,64p | cut -c1-140
cp /tmp/ga/old/addons/NativeAdrenoMetal.primelist "$OUT/prime-list.txt"; wc -l "$OUT/prime-list.txt"
grep -v -E '^/' "$OUT/prime-list.txt" | wc -l
