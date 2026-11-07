/** @file
  Starts USB core 0 in firmware, through the stock UsbInitDxe protocol, so the kernel's QcomXnuUsbDebug finds
  the controller ready on a normal boot. It only makes the one call; UsbInitDxe's exit-boot handler closes its event and does not stop the controller.
  Protocol layout read from the nuwa UsbInitDxe binary: revision, QueryCoreCount, QueryCoreInfo, StartController, StopController.
**/
#include <Uefi.h>
#include <Library/DebugLib.h>
#include <Library/UefiBootServicesTableLib.h>

#define FUXI_USB_INIT_GUID \
  { 0x2da15ac7, 0x4909, 0x4c4c, { 0xb8, 0xc3, 0xa7, 0x42, 0x19, 0x5e, 0xa4, 0x6e } }

typedef struct {
  UINT64 Revision;
  VOID   *QueryCoreCount;
  VOID   *QueryCoreInfo;
  EFI_STATUS (EFIAPI *StartController)(VOID *This, UINT32 Core, UINT32 Flags);
  VOID   *StopController;
} FUXI_USB_INIT_PROTOCOL;

EFI_STATUS
EFIAPI
FuxiUsbStartEntry (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  EFI_GUID                Guid = FUXI_USB_INIT_GUID;
  FUXI_USB_INIT_PROTOCOL  *Init;
  EFI_STATUS              Status;

  Status = gBS->LocateProtocol (&Guid, NULL, (VOID **)&Init);
  if (EFI_ERROR (Status)) {
    DEBUG ((DEBUG_ERROR, "FuxiUsbStart: no UsbInit protocol: %r\n", Status));
    return EFI_SUCCESS;
  }

  Status = Init->StartController (Init, 0, 1);
  DEBUG ((DEBUG_ERROR, "FuxiUsbStart: StartController: %r\n", Status));
  return EFI_SUCCESS;
}
