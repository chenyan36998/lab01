#ifndef __DEVICE_H__
#define __DEVICE_H__
typedef struct _region
{
    uint64_t pbase;
    uint64_t vbase;
    uint64_t size;
    unsigned int directmap;
}region_t;

#define SHARED_BSS        __attribute__((section(".shared_bss")))
#define SHARED_RO         __attribute__((section(".shared_ro")))

extern const region_t SHARED_RO ksram;
extern const region_t SHARED_RO ksdev;
#endif
