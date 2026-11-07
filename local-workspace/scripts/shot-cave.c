/* Screenshot provider for the t50 kernel, placed over the start of copyio_test (a kernel self test nothing runs at boot). With sheng-fb-gpu=1 the GPU writes frames into
 * the GOP scanout memory, so that mapping holds the picture. Every third pixel in each direction, so a frame is 360x800 and small enough for the serial channel. */
typedef unsigned char u8;
typedef unsigned int u32;
typedef unsigned long u64;

__attribute__((noinline)) static int capture(void *cookie, u8 *rgb, u64 capacity, u32 *width, u32 *height)
{
  (void)cookie;
  u64 video[18];
  const volatile u8 *base = *(const volatile u8 *const volatile *)ADDR_GOP_VIRTUAL;
  u32 w = *(const volatile u32 *)ADDR_GOP_WIDTH, h = *(const volatile u32 *)ADDR_GOP_HEIGHT;
  if (!base || !w || !h || ((int (*)(u64 *))ADDR_PE_CURRENT_CONSOLE)(video))
    return 0;
  u64 stride = video[1];
  u32 outw = w / 3, outh = h / 3;
  if (stride < (u64)w * 4 || (u64)outw * outh * 3 > capacity)
    return 0;
  for (u32 y = 0; y < outh; y++) {
    const volatile u32 *row = (const volatile u32 *)(base + (u64)y * 3 * stride);
    for (u32 x = 0; x < outw; x++) {
      u32 p = row[x * 3] & 0xf8f8f8;   /* 5 bits per colour: gradients become runs, which the driver's RLE can shrink */
      *rgb++ = (u8)(p >> 16);
      *rgb++ = (u8)(p >> 8);
      *rgb++ = (u8)p;
    }
  }
  *width = outw;
  *height = outh;
  return 1;
}

/* native_legacy_gop_mapping_checkpoint branches here after publishing the mapping. Registering twice only fails. */
void shot_entry(void)
{
  ((int (*)(void *, void *))ADDR_REGISTER_SCREENSHOT)((void *)capture, 0);
}
