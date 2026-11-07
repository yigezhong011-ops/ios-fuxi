#!/bin/bash
set -euo pipefail
cd /root/hackios
mkdir -p out
cat > out/hello.c <<'EOF'
#include <Uefi.h>

EFI_STATUS
EFIAPI
efi_main (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  SystemTable->ConOut->OutputString (SystemTable->ConOut, L"HELLO FROM THE PAYLOAD\r\n");
  SystemTable->ConOut->OutputString (SystemTable->ConOut, L"If you can read this, the payload path works.\r\n");
  for (;;) {
    SystemTable->BootServices->Stall (1000000);
  }
  return EFI_SUCCESS;
}
EOF
CLANG=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi/toolchain/clang
"$CLANG" --target=aarch64-unknown-windows -ffreestanding -fshort-wchar -mgeneral-regs-only -O1 \
  -I/root/UniXNU/out/feeds/mu_basecore-8f10084c/MdePkg/Include \
  -I/root/UniXNU/out/feeds/mu_basecore-8f10084c/MdePkg/Include/AArch64 \
  -c out/hello.c -o out/hello.obj
lld-link /subsystem:efi_application /entry:efi_main /nodefaultlib /base:0xA1000000 /out:out/hello.efi out/hello.obj
ls -lh out/hello.efi
echo "=== 用 hello 当 payload ==="
python3 xnuloader/mkpayload.py -o out/hello-payload.bin loader.efi=out/hello.efi --usb
FD_BASE=0xA7100000 FD_SIZE=0x300000 PAYLOAD_BASE=0xA8000000 UEFI_TARGET=fuxi \
UEFI_FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
python3 mkxnuimg.py -p out/hello-payload.bin -o out/fuxi-hello.img 2>&1 | tail -4
cp out/fuxi-hello.img /mnt/e/DSH-Fuxi/fuxi-hello.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-hello.img
