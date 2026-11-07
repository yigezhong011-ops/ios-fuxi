#!/bin/bash
# Does the t32 kernel or GPU addon path know a way to drop the MobileGestalt cache on Data?
K=/root/fuxi/t32/kernel.macho
strings -n 6 $K | grep -iE 'mobilegestalt|gestalt|mgcache|mg-reset|data-reset|data-clear|purge|sheng-data' | sort -u | head -30
echo "### addon install paths (how the kernel writes addon files into Data)"
strings -n 6 $K | grep -E '/private/var/(ngpu|containers|mobile)' | sort -u | head -20
