/*
 * The libdrm of xf86drm.h for fuxi: Linux's DRM requests to the kernel's GPU driver
 * as calls of the NativeAdreno user client (xnu/fuxi-adreno/NativeAdrenoABI.h).
 *
 * This is the fuxi counterpart of hackios-xnu-userland's redwood_drm.c; the shape of
 * the file (a fake file descriptor, one connection per process, the request number as
 * the selector) is theirs, the requests behind it are ours:
 *
 *   DRM_IOCTL_MSM_GET_PARAM   -> GetDeviceInfo + Query   (chip id, GMEM, UBWC, VA range)
 *   DRM_IOCTL_MSM_GEM_NEW     -> BoAlloc
 *   DRM_IOCTL_MSM_GEM_INFO    -> bookkeeping (sizes are kept on our side)
 *   DRM_IOCTL_MSM_GEM_CPU_PREP-> BoCpuMap / BoCpuUnmap (cache maintenance)
 *   DRM_IOCTL_MSM_GEM_MMAP    -> BoCpuMap token + IOConnectMapMemory64
 *   DRM_IOCTL_MSM_GEM_SUBMIT  -> Submit (buffers carry handle/iova/bytes; no relocs)
 *   DRM_IOCTL_MSM_WAIT_FENCE  -> WaitFence
 *   DRM_IOCTL_MSM_GEM_CLOSE   -> BoFree
 *
 * The GPU addresses are the client's: the ABI reports NativeAdrenoDeviceClientIova and
 * BoMap takes the iova, which is the has_set_iova path freedreno already has.
 *
 * NOT YET VERIFIED ON HARDWARE. The parts that need the board's real numbers (chip id
 * matching Mesa's fd_dev_info table, UBWC layout) are marked TODO.
 */
#include <errno.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <IOKit/IOKitLib.h>

#include "xf86drm.h"
#include "drm-uapi/msm_drm.h"
#include "NativeAdrenoABI.h"

#define FUXI_GPU_SERVICE_CLASS  "NativeAdrenoGpuPublished"
#define FUXI_GPU_SERVICE_NAME   "NativeAdrenoGpu"

static io_connect_t connection = MACH_PORT_NULL;
static int connection_fd = -1;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

/* Sizes are not part of the alloc reply; keep what we handed out. */
#define MAX_BOS 4096
struct bo_entry {
	uint64_t handle;
	uint64_t bytes;
	uint32_t token;
	bool token_valid;
};
static struct bo_entry bos[MAX_BOS];
static unsigned n_bos;

static struct bo_entry *
bo_find(uint64_t handle)
{
	for (unsigned i = 0; i < n_bos; i++) {
		if (bos[i].handle == handle) {
			return &bos[i];
		}
	}
	return NULL;
}

static struct bo_entry *
bo_add(uint64_t handle, uint64_t bytes)
{
	if (n_bos >= MAX_BOS) {
		return NULL;
	}
	struct bo_entry *e = &bos[n_bos++];
	memset(e, 0, sizeof(*e));
	e->handle = handle;
	e->bytes = bytes;
	return e;
}

static void
bo_remove(uint64_t handle)
{
	for (unsigned i = 0; i < n_bos; i++) {
		if (bos[i].handle == handle) {
			bos[i] = bos[--n_bos];
			return;
		}
	}
}

static int
errno_from_kern(kern_return_t r)
{
	switch (r) {
	case KERN_SUCCESS: return 0;
	case kIOReturnBadArgument: return EINVAL;
	case kIOReturnNoMemory: return ENOMEM;
	case kIOReturnNoResources: return EBUSY;
	case kIOReturnUnsupported: return ENOSYS;
	case kIOReturnNotPermitted: return EACCES;
	case kIOReturnNotFound: return ENOENT;
	case kIOReturnTimeout: return ETIMEDOUT;
	case kIOReturnBusy: return EBUSY;
	default: return EIO;
	}
}

static int
call(unsigned selector, void *in, size_t in_size, void *out, size_t *out_size)
{
	if (connection == MACH_PORT_NULL) {
		return -ENODEV;
	}
	size_t have = out_size ? *out_size : 0;
	kern_return_t r = IOConnectCallStructMethod(connection, selector, in, in_size, out, &have);
	if (out_size) {
		*out_size = have;
	}
	return -errno_from_kern(r);
}

/* ---- open / close ---------------------------------------------------- */

int
drmOpenWithType(const char *name, const char *busid, int type)
{
	(void)busid;
	(void)type;
	if (name != NULL && strcmp(name, "msm") != 0) {
		return -1;
	}
	pthread_mutex_lock(&lock);
	if (connection_fd < 0) {
		io_service_t service = IOServiceGetMatchingService(0, IOServiceMatching(FUXI_GPU_SERVICE_CLASS));
		if (service == MACH_PORT_NULL) {
			service = IOServiceGetMatchingService(0, IOServiceMatching(FUXI_GPU_SERVICE_NAME));
		}
		if (service != MACH_PORT_NULL) {
			io_connect_t conn = MACH_PORT_NULL;
			if (IOServiceOpen(service, mach_task_self(), 0, &conn) == KERN_SUCCESS) {
				connection = conn;
				connection_fd = open("/dev/null", O_RDWR | O_CLOEXEC);
				if (connection_fd < 0) {
					IOServiceClose(connection);
					connection = MACH_PORT_NULL;
				}
			}
			IOObjectRelease(service);
		}
	}
	int fd = connection_fd;
	pthread_mutex_unlock(&lock);
	return fd;
}

int
drmGetDevices2(uint32_t flags, drmDevicePtr devices[], int max_devices)
{
	(void)flags;
	if (devices == NULL || max_devices <= 0) {
		return 1;
	}
	drmDevicePtr d = calloc(1, sizeof(*d));
	if (d == NULL) {
		return -ENOMEM;
	}
	d->bus_type = DRM_BUS_PLATFORM;
	d->available_nodes = 1 << DRM_NODE_RENDER;
	strncpy(d->nodes[DRM_NODE_RENDER], "/dev/null", sizeof(d->nodes[0]) - 1);
	devices[0] = d;
	return 1;
}

void
drmFreeDevices(drmDevicePtr devices[], int count)
{
	for (int i = 0; i < count; i++) {
		free(devices[i]);
	}
}

int
drmGetDevice2(int fd, uint32_t flags, drmDevicePtr *device)
{
	(void)fd;
	(void)flags;
	if (device == NULL) {
		return -EINVAL;
	}
	drmDevicePtr d = calloc(1, sizeof(*d));
	if (d == NULL) {
		return -ENOMEM;
	}
	d->bus_type = DRM_BUS_PLATFORM;
	d->available_nodes = 1 << DRM_NODE_RENDER;
	strncpy(d->nodes[DRM_NODE_RENDER], "/dev/null", sizeof(d->nodes[0]) - 1);
	*device = d;
	return 0;
}

void
drmFreeDevice(drmDevicePtr *device)
{
	if (device != NULL && *device != NULL) {
		free(*device);
		*device = NULL;
	}
}

int
drmDevicesEqual(drmDevicePtr a, drmDevicePtr b)
{
	return a == b;
}

/* ---- parameters ------------------------------------------------------ */

static int
get_device_info(uint32_t *chip_id, uint32_t *gmem_bytes, uint64_t *gmem_base,
                uint64_t *va_start, uint64_t *va_size, uint32_t *flags,
                uint32_t *ubwc_version, uint32_t *ubwc_swizzle, uint32_t *macrotile)
{
	struct NativeAdrenoAbiDeviceInfo info;
	size_t n = sizeof(info);
	int r = call(-call(NativeAdrenoMethodGetDeviceInfo, NULL, 0, &info, &n), NULL, 0, NULL, NULL);
	if (r < 0) {
		return r;
	}
	/* the call() above returns a negative errno; the || keeps it simple */
	return 0;
}
