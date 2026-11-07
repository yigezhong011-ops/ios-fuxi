#!/bin/bash
# Read-only: can the t50 kernel limit which cores the scheduler uses, without a kernel build?
K=/root/fuxi/t50/kernel.macho
ls -l $K
llvm-nm $K 2>/dev/null | grep -E ' _(sched_perfcontrol_update_recommended_cores|sched_usercontrol_update_recommended_cores|sched_update_recommended_cores|sched_override_available_cores|perfcontrol_requested_recommended_cores|usercontrol_requested_recommended_cores|sched_processor_change_mode|processor_exit|processor_exit_from_user|processor_start|sched_choose_processor|choose_processor|sched_edge_init|sched_amp_init|sched_clutch_init)$'
llvm-nm $K 2>/dev/null | grep -i -E 'recommended_cores|recommended_core' | head -30
echo '--- strings'
strings -a $K | grep -E '^(sched_recommended_cores|sched_[a-z_]*cores[a-z_]*|cpus|kern\.sched_recommended_cores|sched_recommended_cores_[a-z]*|cluster_type|cpu-capacity|enable_skstb|sched_enable_smt|sched_allow_[a-z_]*|unixnu[-a-z]*cluster[-a-z]*)$' | sort -u | head -30
strings -a $K | grep -E 'sched_(default_|)policy|Dualq|sched_clutch|Clutch|Edge|edge_' | sort -u | head -15
