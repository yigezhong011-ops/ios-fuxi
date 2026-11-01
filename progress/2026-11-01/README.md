# Xiaomi 13 (fuxi) — progress of 2026-11-01

Everything below runs through `fastboot boot` / `fastboot flash boot_b` of UniXNU boot images (iPadOS 17.7.11 userland).
No image, kernel, key or device seed is in this folder: only notes and the scripts that produced the results.

## Where it stands

| Area | State | Notes |
| --- | --- | --- |
| Desktop | ✅ | third-party image `boot-touch-t32` (another porter's kernel) reaches the iPadOS home screen |
| Touch | ✅ | ST FingerTip FTM5 (chip id `36 40`), not Novatek. Proven twice: in our own kernel with OddlyLabs' FTS probe, and in t32 |
| Frame rate | ✅ ~60 fps by eye | t32 + `sheng-fb-gpu=1` + `sheng-gpu-pause-us=100`, diagnostic page off ([REPORT-t32-perf.md](REPORT-t32-perf.md)) |
| 120 Hz | ❌ | the ABL lights the panel at 60 Hz; the stock DT's `timing@1` switch command (`… 60 00 …`) would need a DSI command path |
| Buttons | 🟡 | PMIC read works (injected poller, 8 changes seen); the HID layer does not hand them to iOS yet (see below) |
| iOS (iPhone) UI | ❌ | identity-only switch (`iPhone10,3`/`phone` in the ADT) keeps the iPad layout; needs an iOS root (UniXNU docs: iPhone X 16.7.16) |
| Slot a | ❌ | `fastboot boot` gives `Load Error` and normal boot falls back to fastboot; slot b works |

## Touch

- OddlyLabs' own image (their uefi-fuxi firmware + v0 boot image + their kernel) hangs after the MMU-on stage on this phone, whatever the loader;
  their port has no device boot evidence.
- Our format-1 tree (the one that reaches `bsd_init`) with Novatek's `TouchProbe.cpp` swapped for OddlyLabs' `FuxiTouchProbe.cpp`
  (+ `FtsProtocol`, `FtsTouchCore`, `QcomRpmh`, `QcomGeniSpi@eac47ba`) draws contacts on the diagnostic page's touch box
  (`yigezhong011-ops/unixnu-fuxi` branch `fts-touch`). The `native_touch_*` interface is identical, so the HID layer reads it unchanged.

## Frame rate (t32)

| Change | Effect |
| --- | --- |
| `sheng-fb-gpu=1` (t32 ships 0) | GPU copies instead of 65–133 ms CPU copies |
| `sheng-gpu-pause-us=100` (default 1000) | biggest step: the fence waiter stops sleeping 1 ms per poll |
| diagnostic page off | small gain |
| GPU / CPU frequency locks | no gain (GPU ~0.6 ms per composition, CPU mostly idle) |
| `sheng-dpu-scanout=2` | worse on fuxi: falls back to CPU copies, not GPU copies |

## Buttons (t32)

- t32's `native_buttons_set_sink` is a bare `ret`, so no button source exists. fuxi's keys match sheng's exactly
  (PMK8550 PON ppid 0x013 bits 7/6, PM8550 GPIO6 ppid 0x18d active low, SPMI arbiter v7 at 0xc400000, EE 0).
- `scripts/wsl/fuxi-buttons-blob.c` (poller, reads only, 20 ms) is injected into a code cave after `__hib_text` by
  `scripts/wsl/patch-t32-buttons.py`, with the `ret` turned into a branch. Its state shows on the diagnostic page's CPU row:
  `BTN s50 v70000001 a300 p230 g247 r10 u1 m0 n8` — arbiter found, both APIDs found, key changes detected and passed to `buttonsNotify`.
- `NativeHidInput::buttonsAction` sends report 2 only after `eventDriver()` finds an in-kernel `IOHIDEventDriver` below the device
  (same as ShengHidInput's `hasEventDriverCached`). Forcing the report without it panics (the phone resets and boots boot_b).
  Open: why no `IOHIDEventDriver` attaches to the input device on 21H461.

## Files

- [STATUS-2026-11-01-touch.md](STATUS-2026-11-01-touch.md) — the touch bring-up log, images and results
- [REPORT-t32-perf.md](REPORT-t32-perf.md) — frame-rate measurements and the button findings, for the t32 author
- [REQUEST-ljhhkx529-touch.md](REQUEST-ljhhkx529-touch.md) — the request to put the FTS probe into ljhhkx529's build
- `scripts/wsl/` — image packing (`build-fts3.sh`, `pack-payload.sh`, `make-arg-variant.sh`), entry-probe bisecting, ADT tools
  (`adt-edit.py`, `adt-tree.py`, `adt-node-props.py`), CI helpers, the button poller and its patcher
- `scripts/win/` — Windows-side kernel extraction and symbol / cave analysis without WSL
