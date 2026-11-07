#!/bin/bash
# Read-only: find GpuPowerProbe.cpp and show the coherence probe.
F=$(find /root -name GpuPowerProbe.cpp -not -path '/root/.cache/*' 2>/dev/null | head -1)
echo "FILE=$F"
[ -n "$F" ] || exit 1
grep -nE 'gCoherence|coherenceProbe|int-143|int-150' "$F" | cut -c1-140 | head -40
S=$(grep -n 'gCoherenceAttempts *=\|gCoherenceAttempts++\|gCoherenceAttempts = ' "$F" | head -1 | cut -d: -f1)
echo "--- around attempts line $S"
[ -n "$S" ] && sed -n "$((S-25)),$((S+95))p" "$F" | cut -c1-130
