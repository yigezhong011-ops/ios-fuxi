#!/bin/bash
# Read-only: the recommended-cores entry points and any guard at their start.
K=/root/fuxi/t50/kernel.macho
llvm-objdump -d --start-address=0xfffffff00b8e36c0 --stop-address=0xfffffff00b8e3830 $K 2>/dev/null | tail -n +7 | cut -c1-100
echo '--- guard at 0xb8e35dc'
llvm-objdump -d --start-address=0xfffffff00b8e35dc --stop-address=0xfffffff00b8e3600 $K 2>/dev/null | tail -n +7 | cut -c1-100
llvm-nm $K | grep -E ' _(cpus_defeatured|sched_[a-z_]*recomm[a-z_]*|sched_powered_cores|processor_avail_count_user|sched_cpu_[a-z_]*)$' | head
