#!/bin/bash
# What lies around the code cave at the end of __TEXT_EXEC in the t32 kernel (sections, load commands, symbols)
K=/root/fuxi/t32/kernel.macho
llvm-objdump --section-headers "$K" | grep -i -E 'hib|lastpage|__text|BOOT|KLD|PPL' | head -20
echo "== segments"
llvm-otool -l "$K" 2>/dev/null | grep -A3 -E 'segname (__TEXT_EXEC|__KLD|__LAST|__TEXT_BOOT_EXEC|__PPLTEXT|__BOOTDATA|__LASTDATA_CONST)' | grep -E 'segname|vmaddr|vmsize|filesize' | head -40
echo "== symbols 0xc08c000..0xc094000"
llvm-nm -n "$K" | awk '$1 >= "fffffff00c08c000" && $1 <= "fffffff00c094000"' | head -20
