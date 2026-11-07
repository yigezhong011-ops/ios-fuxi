#!/bin/bash
# Boot-arg names near the Setup-skip code in the t32 and t36 kernels (purplebuddy / skip-setup / setup-done).
for K in /root/fuxi/t32/kernel.macho /root/fuxi/t36/kernel.macho; do
  echo "########## $K"
  strings -n 6 $K | grep -iE 'skip-setup|skip_setup|setup-done|skipsetup|purplebuddy|SetupDone|sheng-setup|fuxi-setup|-setup=' | sort -u | head -20
done
