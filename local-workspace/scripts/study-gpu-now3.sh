#!/bin/bash
M=/root/fuxi/src-adrenometal; A=/root/fuxi/src-adreno740
echo "== 8c1ea13 in full"
git -C $M log -1 --format='%B' 8c1ea13 | cut -c1-900
git -C $M show --stat --format= 8c1ea13 | tail -22 | cut -c1-90
echo "== 5a50581"; git -C $M show --stat --format= 5a50581 | tail -6 | cut -c1-90
git -C $M show --format= 5a50581 | grep -E '^[-+]' | grep -v -E '^(\+\+\+|---)' | cut -c1-170 | head -24
echo "== does it apply on our pin"
for c in 8c1ea13 5a50581; do
  T=$(git -C $M merge-tree --write-tree --merge-base=$c~1 7e0d3d2 $c 2>&1 | head -30)
  echo "-- $c: $(echo "$T" | grep -c '^CONFLICT') conflicts"; echo "$T" | grep '^CONFLICT' | cut -c1-120 | head -8
done
echo "== where the client slots are"
git -C $A grep -n -E '\[4\]|== *4\b|< *4\b|kContexts|kMaxContexts|kPrivate|contextSlots|clientSlot|slots_' 759d646 -- '*.cpp' '*.h' 2>/dev/null | sed -e 's/^759d646://' | grep -i -E 'client|context|slot|asid|pagetable|ttbr|table' | cut -c1-170 | head -14
git -C $A grep -n -E 'slots|four' 759d646 -- README.md docs 2>/dev/null | sed -e 's/^759d646://' | cut -c1-210 | head -10
echo "== sample count at our pin"
git -C $M grep -n -i -E 'sampleCount|single.?sample|setRasterSampleCount|supportsTextureSampleCount|supportsExtendedXR10Formats' 7e0d3d2 -- 'NativeAdrenoMetalPlugin.mm' '*.h' 2>/dev/null | sed -e 's/^7e0d3d2://' | cut -c1-160 | head -10
