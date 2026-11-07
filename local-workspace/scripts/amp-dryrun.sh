#!/bin/bash
# Dry run in a scratch dir under /root/fuxi/amp-try: the three XNU files with every earlier patch that touches them, then AMP.
# Nothing is built and no repository is changed.
E=/mnt/e/DSH-Fuxi; T=$(tr -d '\r\n ' < $E/token2.txt); W=/root/fuxi/amp-try
api() { curl -fsSL -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github+json' "$@"; }
R=/root/fuxi/ref-fuxi-v2; O=origin/old; U=/root/fuxi/up-latest; P=$(git -C /root/fuxi/unixnu-pin rev-parse HEAD)
rm -rf $W; mkdir -p $W/x $W/p; cd $W/x; git init -q .
X=d8b80295118ef25ac3a784134bcf95cd8e88109f
FILES="pexpert/pexpert/arm64/BCM2837.h pexpert/pexpert/arm64/board_config.h osfmk/kern/sched_clutch.c"
for f in $FILES; do mkdir -p $(dirname $f); curl -fsSL https://raw.githubusercontent.com/apple-oss-distributions/xnu/$X/$f -o $f || echo "NO $f"; done
wc -l $FILES | tail -4; git add -A; git -c user.name=a -c user.email=a@a commit -qm base
echo "=== profile series at pin"
git -C $U ls-tree -r --name-only $P profiles/arch/arm64 | head -8
git -C $U ls-tree -r --name-only $P profiles | grep -iE 'patch|series' | wc -l
# Common patches at the pin (UniXNU's own patches/xnu), then the board's: format 1 sorts one directory, so check both layouts.
mkdir -p $W/p/up $W/p/old
for n in $(git -C $U ls-tree -r --name-only $P patches/xnu kits/XnuPrelink/patches 2>/dev/null | grep '\.patch$'); do git -C $U show $P:$n > $W/p/up/$(basename $n) 2>/dev/null; done
for n in $(git -C $R ls-tree -r --name-only $O patches/xnu kits/XnuPrelink/patches | grep '\.patch$'); do git -C $R show $O:$n > $W/p/old/$(basename $n); done
git -C $R show origin/V2:patches/xnu/zzyf-sheng-amp.patch > $W/p/amp.patch
ls $W/p/up | wc -l; ls $W/p/old | wc -l
inc="--include=pexpert/pexpert/arm64/BCM2837.h --include=pexpert/pexpert/arm64/board_config.h --include=osfmk/kern/sched_clutch.c"
for p in $(ls $W/p/old/*.patch | LC_ALL=C sort); do
  if grep -qE '^\+\+\+ b/(pexpert/pexpert/arm64/(BCM2837|board_config)\.h|osfmk/kern/sched_clutch\.c)' $p; then
    if git apply $inc --whitespace=nowarn $p 2>/tmp/e; then echo "ok   $(basename $p)"; else echo "FAIL $(basename $p): $(head -2 /tmp/e | cut -c1-110 | tr '\n' ' ')"; fi
  fi
done
echo "=== AMP"
if git apply --check --whitespace=nowarn $W/p/amp.patch 2>/tmp/e; then echo "AMP applies clean"; git apply --whitespace=nowarn $W/p/amp.patch; else echo "AMP FAILS"; cut -c1-140 /tmp/e | head -12; fi
grep -n 'MAX_CPU' pexpert/pexpert/arm64/board_config.h | tail -4 | cut -c1-90
grep -n 'BCM2837' -A10 pexpert/pexpert/arm64/board_config.h | grep -E 'SCHED|CPU_CLUSTERS' | cut -c1-90
grep -rn 'CONFIG_SCHED_EDGE' /dev/null; curl -fsSL https://raw.githubusercontent.com/apple-oss-distributions/xnu/$X/osfmk/kern/sched.h 2>/dev/null | grep -n 'SCHED_EDGE' | head -3
curl -fsSL https://raw.githubusercontent.com/apple-oss-distributions/xnu/$X/osfmk/conf/MASTER 2>/dev/null | grep -n 'edge' | cut -c1-90 | head
for f in osfmk/kern/kern_types.h osfmk/kern/sched_prim.h osfmk/kern/processor.h; do curl -fsSL https://raw.githubusercontent.com/apple-oss-distributions/xnu/$X/$f | grep -n 'CONFIG_SCHED_EDGE' | head -3 | sed "s#^#$f: #"; done
echo "=== Kerfand CI"
for r in Kerfand/unixnu-ci Kerfand/UniXNU Kerfand/unixnu-fuxi0721; do
  echo "--- $r"; api "https://api.github.com/repos/$r/actions/runs?per_page=10" 2>/dev/null | python3 -I -c "
import json,sys
for x in json.load(sys.stdin)['workflow_runs']: print(x['id'],x['created_at'][:16],x['head_branch'],x['conclusion'],x['name'][:40])" 2>/dev/null
done
api "https://api.github.com/repos/Kerfand/unixnu-ci/contents/.github/workflows" | python3 -I -c "import json,sys; print([f['name'] for f in json.load(sys.stdin)])" 2>/dev/null
