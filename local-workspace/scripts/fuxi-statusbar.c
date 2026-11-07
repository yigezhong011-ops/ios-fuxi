// Fuxi: a phone status bar on the 1080 x 2400 panel, 21H461 arm64 only. Loaded through a weak load command in the Metal plugin.
// UIKit and SystemStatusUI know no iPhone with 360 x 800 points, so they choose the Fallback provider, whose only item is the red rdar
// label. Each keeps its choice for the embedded screen in one static variable, read first by the selection function: put a 1080 wide
// phone provider there and rebuild the bars that exist. Regions, clock and battery stay the system's own; nothing is drawn or faked.
// Built with no SDK, so the few declarations it needs are here.
typedef unsigned long uintptr_t;
typedef void *id, *Class, *SEL, *Ivar, *Method, *IMP;
extern Class objc_lookUpClass(const char *), objc_allocateClassPair(Class, const char *, unsigned long), object_getClass(id);
extern void objc_registerClassPair(Class), objc_msgSend(void);
extern SEL sel_registerName(const char *);
extern int class_addMethod(Class, SEL, IMP, const char *);
extern Ivar class_getInstanceVariable(Class, const char *);
extern Method class_getInstanceMethod(Class, SEL), class_getClassMethod(Class, SEL);
extern IMP method_getImplementation(Method), method_setImplementation(Method, IMP);
extern const char *method_getTypeEncoding(Method);
extern id object_getIvar(id, Ivar);
extern void object_setIvarWithStrongDefault(id, Ivar, id);
extern void *dlsym(void *, const char *);
extern const char *getprogname(void);
extern int strcmp(const char *, const char *);
extern void syslog(int, const char *, ...);
extern unsigned mach_task_self_;
extern int vm_read_overwrite(unsigned, uintptr_t, uintptr_t, uintptr_t, uintptr_t *);
extern int vm_write(unsigned, uintptr_t, uintptr_t, unsigned);
extern char _dispatch_main_q;
extern unsigned long long dispatch_time(unsigned long long, long long);
extern void dispatch_async_f(void *, void *, void (*)(void *));
extern void dispatch_after_f(unsigned long long, void *, void *, void (*)(void *));
#define RTLD_DEFAULT ((void *)-2)
#define LOG_NOTICE 5
#define SEND0(object, name) ((void (*)(id, SEL))objc_msgSend)(object, sel_registerName(name))

struct family {
    const char *bar, *fallback, *medium, *name;
    uintptr_t slot;
    Class fallbackClass;
    Ivar ivar;
    IMP layout;
    unsigned repairs, done;
};
static struct family families[2] = {
    {"_UIStatusBar", "_UIStatusBarVisualProvider_Fallback", "_UIStatusBarVisualProvider_DynamicSplitMedium", "FuxiStatusBarProvider", 0x1f48d71d8},
    {"STUIStatusBar", "STUIStatusBarVisualProvider_Fallback", "STUIStatusBarVisualProvider_DynamicSplitMedium", "FuxiSystemStatusProvider", 0x1f5abb700},
};
// A class query the selection reads and DynamicSplitMedium lacks. It must not ask UIScreen, which may be starting up.
static double referenceScale(id self, SEL selector) {return 3.0;}
// The provider asks the screen's _exclusionArea where the island is, for the time's height and the gap in the middle. Answer with
// where the island is drawn here (measured on a screenshot, in points): without this the time and battery sit above its centre.
struct rect {double x, y, width, height;};
static struct rect sensorArea(id self, SEL selector) {return (struct rect){118, 12, 125, 36};}
// A bar built before the slot was written holds Fallback. If the selection still answers Fallback this stays bounded.
static void repair(struct family *f, id bar) {
    id current = f->ivar ? object_getIvar(bar, f->ivar) : 0;
    if (!current || object_getClass(current) != f->fallbackClass || f->repairs >= 12) return;
    f->repairs++;
    SEND0(bar, "resetVisualProvider");
    object_setIvarWithStrongDefault(bar, f->ivar, 0);
    ((void (*)(id, SEL, Class))objc_msgSend)(bar, sel_registerName("_setVisualProviderClass:"), 0);
    SEND0(bar, "_prepareVisualProviderIfNeeded");
    SEND0(bar, "setNeedsLayout");
    syslog(LOG_NOTICE, "fuxi status bar: rebuilt a %s, repair %u", f->bar, f->repairs);
}
static void layout0(id self, SEL selector) {repair(&families[0], self); ((void (*)(id, SEL))families[0].layout)(self, selector);}
static void layout1(id self, SEL selector) {repair(&families[1], self); ((void (*)(id, SEL))families[1].layout)(self, selector);}
static void install(struct family *f, IMP replacement, uintptr_t slide) {
    Class bar = objc_lookUpClass(f->bar), fallback = objc_lookUpClass(f->fallback), medium = objc_lookUpClass(f->medium);
    if (!bar || !fallback || !medium) return;
    uintptr_t current = 0, got = 0;
    if (vm_read_overwrite(mach_task_self_, f->slot + slide, sizeof current, (uintptr_t)&current, &got) || got != sizeof current ||
        (current && current != (uintptr_t)fallback)) {
        syslog(LOG_NOTICE, "fuxi status bar: %s keeps its provider %lx", f->bar, current);
        f->done = 1;
        return;
    }
    Class provider = objc_allocateClassPair(medium, f->name, 0);
    if (!provider) return;
    class_addMethod(object_getClass(provider), sel_registerName("referenceScreenScale"), (IMP)referenceScale, "d16@0:8");
    class_addMethod(provider, sel_registerName("sensorAreaRect"), (IMP)sensorArea, "{CGRect={CGPoint=dd}{CGSize=dd}}16@0:8");
    objc_registerClassPair(provider);
    f->fallbackClass = fallback;
    f->ivar = class_getInstanceVariable(bar, "_visualProvider");
    uintptr_t value = (uintptr_t)provider;
    int status = vm_write(mach_task_self_, f->slot + slide, (uintptr_t)&value, sizeof value);
    SEL selector = sel_registerName("layoutSubviews");
    Method method = class_getInstanceMethod(bar, selector);
    if (!status && method && f->ivar) {
        f->layout = method_getImplementation(method);
        if (!class_addMethod(bar, selector, replacement, method_getTypeEncoding(method))) method_setImplementation(method, replacement);
    }
    f->done = 1;
    syslog(LOG_NOTICE, "fuxi status bar: %s uses %s, slot was %lx, write %d", f->bar, f->name, current, status);
}
// A bar that lays out no more, such as the lock screen's, never reaches the layout hook: look for the bars in every window.
static void sweepView(id view, unsigned depth) {
    SEL kind = sel_registerName("isKindOfClass:");
    for (unsigned i = 0; i < 2; i++) {
        Class bar = objc_lookUpClass(families[i].bar);
        if (bar && families[i].fallbackClass && ((signed char (*)(id, SEL, Class))objc_msgSend)(view, kind, bar)) repair(&families[i], view);
    }
    if (depth >= 40) return;
    id views = ((id (*)(id, SEL))objc_msgSend)(view, sel_registerName("subviews"));
    unsigned long count = ((unsigned long (*)(id, SEL))objc_msgSend)(views, sel_registerName("count"));
    for (unsigned long i = 0; i < count; i++)
        sweepView(((id (*)(id, SEL, unsigned long))objc_msgSend)(views, sel_registerName("objectAtIndex:"), i), depth + 1);
}
static void sweep(void) {
    Class window = objc_lookUpClass("UIWindow");
    SEL all = sel_registerName("allWindowsIncludingInternalWindows:onlyVisibleWindows:");
    if (!window || !class_getClassMethod(window, all)) return;
    id windows = ((id (*)(Class, SEL, signed char, signed char))objc_msgSend)(window, all, 1, 0);
    unsigned long count = ((unsigned long (*)(id, SEL))objc_msgSend)(windows, sel_registerName("count"));
    for (unsigned long i = 0; i < count; i++)
        sweepView(((id (*)(id, SEL, unsigned long))objc_msgSend)(windows, sel_registerName("objectAtIndex:"), i), 0);
}
static void attempt(void *context) {
    uintptr_t left = (uintptr_t)context;
    void *start = dlsym(RTLD_DEFAULT, "CARenderServerStart");
    if (start) {
        uintptr_t slide = (uintptr_t)start - 0x189651efc;
        if (!families[0].done) install(&families[0], (IMP)layout0, slide);
        if (!families[1].done) install(&families[1], (IMP)layout1, slide);
    }
    sweep();
    // SystemStatusUI may load later than this library, and windows keep arriving during startup.
    if (left)
        dispatch_after_f(dispatch_time(0, 2000000000LL), &_dispatch_main_q, (void *)(left - 1), attempt);
}
__attribute__((constructor)) static void start(void) {
    if (!strcmp(getprogname(), "backboardd")) return;   // the process that owns the GPU has no bar; leave it alone
    syslog(LOG_NOTICE, "fuxi status bar: loaded in %s", getprogname());
    dispatch_async_f(&_dispatch_main_q, (void *)30, attempt);
}
