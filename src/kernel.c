#include "uart.h"
#include "io.h"

extern void ldr_test(void);
extern void my_memcpy_test(void);
extern void access_label_test(void);
static const char * const bad_mode_handler[] = {
	"Sync Abort",
	"IRQ",
	"FIQ",
	"SError"
};
void my_ldr_str_test(void)
{

	ldr_test();
	my_memcpy_test();

	memset(0x200004, 0x55, 102);

	access_label_test();


}

extern unsigned long compare_and_return(unsigned long a, unsigned long b);

extern void add_inst_test(void);
extern void ands_test(void);
extern void bitfield_test(void);
extern void cmp_cmn_test(void);
extern unsigned long csel_test(unsigned long r, unsigned long b);
extern void bl_test(void);
extern void adrp_test(void);

void panic(void)
{
        printk("Kernel panic\n");

	while (1)
		;
}

void bad_mode(struct pt_regs *regs, int reason, unsigned int esr)
{
#if 0
	printk("Bad mode for %s handler detected, far:0x%x esr:0x%x - %s\n",
			bad_mode_handler[reason], read_sysreg(far_el1),
			esr, esr_get_class_string(esr));

	parse_esr(esr);

	panic();
#endif
}




void my_data_process_inst(void)
{
	unsigned long ret;
	unsigned long val;

	add_inst_test();

	ret = compare_and_return(10, 9);
	val = compare_and_return(9, 10);

	ands_test();
	bitfield_test();
	cmp_cmn_test();
	val = csel_test(1, 3);

	bl_test();

	adrp_test();
}

void kernel_main(void)
{
	uart_init();
	uart_send_string("Welcome BenOS!\r\n");

	/* my test*/
	my_ldr_str_test();
	my_data_process_inst();

	while (1) {
		uart_send(uart_recv());
	}
}
