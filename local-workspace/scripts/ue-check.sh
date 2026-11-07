#!/bin/bash
# Any [clocks]/USB rows in a decoded log, the last slot times, and the userland progress rows.
D=$(ls -d "$1"/*/ | head -1)
echo "clocks rows: $(grep -c 'clocks' "$D/slots.txt")"
grep -h 'clocks\|CPUFREQ\|USB' "$D/latest.txt" | head
grep -E '^#slot' "$D/slots.txt" | tail -2
grep -E '^X5|^X4' "$D/latest.txt"
