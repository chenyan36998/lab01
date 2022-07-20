//#include "macros.h"
#define KB *(1024)
#define MB *(1024 KB)

#if 0
/* kernel's RAM */
const region_t SHARED_RO ksram[] = {
    {.pbase = 0x80000, .vbase = 0xffff000000080000,,.size = 128 MB},
    {.size = 0},
    {.pbase = 0x80000 + 128 MB, .vbase = 0xffff000000080000  + 128 MB,.size = 128 MB},
};

/* kernel's device */
const region_t SHARED_RO ksdev[] = {
    // UART port. The order follow, does not matter anything.
    {.pbase = DEVICE_PBASE_UART, .vbase = DEVICE_VBASE_UART, .size = DEVICE_SIZE_UART1},
    {.pbase = DEVICE_PBASE_GIC, .vbase = DEVICE_VBASE_GIC, .size = DEVICE_SIZE_GIC},
    {.size = 0}
};
#endif
