#!/usr/bin/env python3
"""File the report on the upstream UniXNU repository (the fuxi device repo has
issues disabled)."""
import json
import pathlib
import urllib.request

TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
REPO = 'UniXNU/UniXNU'
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json'}

TITLE = "fuxi: reaches userland, but GPU switches trap userland; a clean clone cannot build the kernel (xnu-prelink candidates missing)"

BODY = """## Summary

On Xiaomi 13 (fuxi, SM8550, A740) with `UniXNU@main` + `ljhhkx529/unixnu-fuxi@old`
+ `ljhhkx529/uefi-fuxi@old`, the port already reaches userland:

- UEFI → UniXNU menu → DarwinBoot → kernel entry
- display (GOP/PM4) and VM up
- UFS reads the userdata windows (24 万 requests), APFS root mounts, Apple logo shows
- diagnostics list `PROC backboardd` / `PROC SpringBoard`

Two things block further progress, and I would like to know whether they are
expected inputs I am missing, or bugs.

## 1. Any GPU switch kills userland processes

| kernel_args GPU subset | result |
| --- | --- |
| none | ✅ Apple logo, launchd, backboardd, SpringBoard (SpringBoard then exits with NSException) |
| `sheng-fb-gpu=1 sheng-vsync=120` | ❌ black screen, `status=exited sig=5` |
| `sheng-gpu-metal=1 sheng-fb-gpu=1` | ❌ black screen, `sig=5` |
| `sheng-gpu-metal=1 sheng-gpu-addon=1 sheng-fb-gpu=1` | ❌ black screen, `sig=5` |
| full set (adds `sheng-gpu-dcvs`, `sheng-gpu-power=9`) | ❌ kernel `IRQ-off hard lock` |

Diagnostics excerpt:

```
EXIT p229 live/activated status=exited sig=5 exited=0 ne2 sub=5
PROC backboardd p56 ...
PROC SpringBoard p27 ...
FS: total verif=3419ms read=2115ms req=249784
```

`sig=5` looks like a trap after Metal device creation fails.

Also, the device repo pins `qcom/sm8550/fuxi/a740_zap.mbn` as 9,040 bytes /
`e05d28dd…`, while the ZAP extracted from this phone's ODM partition is
12,088 bytes / `fd107982…`. Which one does the A740 path expect?

## 2. A clean clone cannot build the kernel

On `macos-26` + Xcode 26.6 (the `macOS build` workflow), against
`ljhhkx529/unixnu-fuxi@old`:

1. `archive-11-build-sheng-platform-power` fails with
   `No reference candidate available`; `build-sheng-platform-power.py` needs
   `build/native-prelink/*-candidate.macho`, which
   `porting/migration#build-inputs` lists as a required *qualified* input.
2. Building `fuxi_defconfig` (stage 2a) first and staging its kernel as the
   candidate in `out/fuxi/tree/build/native-prelink/` does not survive: the main
   build's `tree` step rebuilds the tree and the candidate is gone.
3. Trying the format 2 branch (`main`) stops earlier:
   `ar: build/software-aes/NativeAES.o: No such file or directory` after
   `archive-05 build-arm-driver.py NativeAES` (which finishes in <1 s).

## Questions

1. Are `build/xnu-prelink/*candidate.macho` + `.json` (and a built
   `kernel/kernel.macho`) artefacts that a port author has to hand out, or is
   there a documented way to produce them from a clean checkout that I missed?
2. For a board that still uses a board-local driver (`NativeAdreno`), is the
   intended path to migrate to the shared `component:Adreno740` (as sheng does)?
   Does the shared component carry the board's firmware selection?
3. Would you accept a patch that makes `pre_build` able to stage the stage-2a
   candidate so the CI can build a board whose archive chain needs it?

## Environment

- fuxi / SM8550 / A740, 1080×2400
- iPadOS 17.7.11 21H461 (Darwin 23.6.0), iPad7,1 userland
- boot: `fastboot boot`; userdata built by `./unixnu build userdata` and flashed
  as a sparse image (8.21 GB)
- platform seed: `--unique-chip-id "${UNIXNU_UNIQUE_CHIP_ID:?set the device platform seed}"`
"""


def call(url, method='GET', data=None):
    req = urllib.request.Request(url, headers={**H, 'Content-Type': 'application/json'},
                                 method=method, data=json.dumps(data).encode() if data else None)
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read().decode()
        return json.loads(body) if body.strip() else {}


issue = call(f'https://api.github.com/repos/{REPO}/issues', method='POST',
             data={'title': TITLE, 'body': BODY})
print('已开 issue:', issue.get('html_url') or issue)
