/* Touch injection + screenshot provider for the t50 kernel, placed over the start of copyio_test
 * (a kernel self test nothing runs at boot), the same cave make-t50-shot.sh uses.
 *
 * Every SCREENSHOT command first publishes one synthetic tap through the driver's own touch sink
 * (the same globals TouchProbe.cpp writes), then captures the frame. Two commands in a row
 * therefore show the screen before and after a tap.
 *
 * Coordinates are in the driver's published units (0..20319, 0.1 px, Y mirrored) — the numbers
 * TouchProbe publishes. The tap point and hold time are TAP_X / TAP_Y / TAP_HOLD_MS.
 */
typedef unsigned char u8;
typedef unsigned int u32;
typedef unsigned long u64;

#ifndef TAP_HOLD_MS
#define TAP_HOLD_MS 40
#endif
#ifndef SWIPE_STEPS
#define SWIPE_STEPS 12
#endif
#ifndef SWIPE_STEP_MS
#define SWIPE_STEP_MS 10
#endif
/* unlock swipe: straight up from near the bottom edge, ending above the middle */
#define SWIPE_X  10160
#define SWIPE_Y0 19000
#define SWIPE_Y1 6500

/* Tap points, in the published axis (0..20319); Y goes through the driver's mirror below.
 * Chosen by switch rather than a table because only .text reaches the cave. The point rotates on
 * every screenshot so one boot can try several spots: 0 = camera button, 1 = flashlight, 2 = middle. */
static void point_for(unsigned phase, int *px, int *py)
{
  switch (phase % 3) {
  case 0: *px = 16370; *py = 18540; break;
  case 1: *px = 3950;  *py = 18540; break;
  default: *px = 10160; *py = 10160; break;
  }
}

/* Touch driver globals, addresses from the kernel's symbol table. */
#define ADDR_TOUCH_SEQ    0xfffffff00c1846ecUL
#define ADDR_TOUCH_COUNT  0xfffffff00c1846f0UL
#define ADDR_TOUCH_XS     0xfffffff00c1846f4UL
#define ADDR_TOUCH_YS     0xfffffff00c184724UL
#define ADDR_TOUCH_IDS    0xfffffff00c184754UL
#define ADDR_TOUCH_SINK   0xfffffff00c2324f0UL
#define ADDR_TOUCH_CTX    0xfffffff00c2324e8UL

static inline u64 counter(void)
{
  u64 v;
  __asm__ volatile("mrs %0, cntvct_el0" : "=r"(v));
  return v;
}

static inline u64 counter_freq(void)
{
  u64 v;
  __asm__ volatile("mrs %0, cntfrq_el0" : "=r"(v));
  return v;
}

/* One publish, the same sequence as TouchProbe.cpp: odd seq, the slots, even seq, then the sink. */
__attribute__((noinline)) static void touch_publish(u32 count, int x, int y)
{
  volatile u32 *seq = (volatile u32 *)ADDR_TOUCH_SEQ;
  *seq = *seq + 1;
  __asm__ volatile("dmb ish" ::: "memory");
  *(volatile u32 *)ADDR_TOUCH_COUNT = count;
  if (count) {
    *(volatile int *)ADDR_TOUCH_XS = x;
    *(volatile int *)ADDR_TOUCH_YS = 20319 - (y > 20319 ? 20319 : y);
    *(volatile int *)ADDR_TOUCH_IDS = 1;
  }
  __asm__ volatile("dmb ish" ::: "memory");
  *seq = *seq + 1;
  void (*sink)(void *) = *(void *volatile *)ADDR_TOUCH_SINK;
  if (sink)
    sink(*(void *volatile *)ADDR_TOUCH_CTX);
}

/* The phase lives in touch slot 1, which a one-finger publish never fills. */
__attribute__((noinline)) static unsigned next_phase(void)
{
  volatile int *slot = (volatile int *)(ADDR_TOUCH_XS + 4);
  unsigned v = (unsigned)(*slot) + 1;
  if (v > 100000u)
    v = 1;
  *slot = (int)v;
  return v;
}

__attribute__((noinline)) static void touch_tap_at(int x, int y)
{
  const u64 freq = counter_freq();
  const u64 start = counter();
  touch_publish(1, x, y);
  while (counter() - start < freq * TAP_HOLD_MS / 1000)
    __asm__ volatile("yield");
  touch_publish(0, x, y);
}

/* Drag from (x0,y0) to (x1,y1) in STEPS frames, so SpringBoard sees a swipe rather than a jump. */
__attribute__((noinline)) static void touch_swipe(int x0, int y0, int x1, int y1)
{
  const u64 freq = counter_freq();
  touch_publish(1, x0, y0);
  for (int i = 1; i <= SWIPE_STEPS; i++) {
    const int x = x0 + (x1 - x0) * i / SWIPE_STEPS;
    const int y = y0 + (y1 - y0) * i / SWIPE_STEPS;
    const u64 t = counter();
    touch_publish(1, x, y);
    while (counter() - t < freq * SWIPE_STEP_MS / 1000)
      __asm__ volatile("yield");
  }
  touch_publish(0, x1, y1);
}

__attribute__((noinline)) static void touch_tap(void)
{
  const unsigned phase = next_phase() - 1;
  if (phase == 0) {
    /* first gesture after boot: swipe up from the bottom to leave the lock screen */
    touch_swipe(SWIPE_X, SWIPE_Y0, SWIPE_X, SWIPE_Y1);
    return;
  }
  int x, y;
  point_for(phase - 1, &x, &y);
  touch_tap_at(x, y);
}

__attribute__((noinline)) static int shot_capture(void *cookie, u8 *rgb, u64 capacity, u32 *width, u32 *height)
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
      u32 p = row[x * 3] & 0xf8f8f8;
      *rgb++ = (u8)(p >> 16);
      *rgb++ = (u8)(p >> 8);
      *rgb++ = (u8)p;
    }
  }
  *width = outw;
  *height = outh;
  return 1;
}

/* The provider the kernel calls for a SCREENSHOT command: tap first, then hand it the frame. */
__attribute__((noinline)) static int capture_and_tap(void *cookie, u8 *rgb, u64 capacity, u32 *width, u32 *height)
{
  touch_tap();
  return shot_capture(cookie, rgb, capacity, width, height);
}

/* Entered from the GOP mapping checkpoint right after the mapping is published. */
void touch_entry(void)
{
  ((int (*)(void *, void *))ADDR_REGISTER_SCREENSHOT)((void *)capture_and_tap, 0);
}
