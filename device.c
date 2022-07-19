
#include "device.h"

/* kernel's RAM */
const region_t SHARED_RO ksram[] = {
    {.pbase = CONFIG_LOAD_ADDR, .vbase = CONFIG_EXEC_ADDR,.size = 128 MB},
    {.size = 0},
    {.pbase = CONFIG_LOAD_ADDR + 128 MB, .vbase = CONFIG_EXEC_ADDR + 128 MB,.size = 128 MB},
};

/* kernel's device */
const region_t SHARED_RO ksdev[] = {
    // UART port. The order follow, does not matter anything.
    {.pbase = DEVICE_PBASE_UART, .vbase = DEVICE_VBASE_UART, .size = DEVICE_SIZE_UART1},
    {.pbase = DEVICE_PBASE_GIC, .vbase = DEVICE_VBASE_GIC, .size = DEVICE_SIZE_GIC},
    {.size = 0}
};
