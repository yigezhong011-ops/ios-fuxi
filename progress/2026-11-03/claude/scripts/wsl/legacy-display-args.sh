#!/bin/bash
# Boot arguments the t36 kernel's display path reads (canvas size / scale / unit-scale), to see whether the reported screen
# size can be set without a code change.
K=/root/fuxi/t36/kernel.macho
strings -n 5 $K | grep -E '^(offline-legacy|sheng-fb|sheng-dpu|native-legacy|legacy-|fuxi-fb|sheng-canvas|offline-mobile|sheng-display|display-)[a-z0-9-]*$' | sort -u
echo "### installBootDimensions / canvas symbols"
llvm-nm $K | grep -iE 'BootDimensions|canvas|legacy_display_(width|height|scale|mode)|native_legacy_display_[a-z_]*(size|dim|scale)' | head -20
