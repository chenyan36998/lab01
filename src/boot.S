#include "mm.h"
#include "sysregs.h"

.section  .rodata
.align 3
.globl el_string1
el_string1:
	.string "Booting at EL"

.section ".text.boot"

/* Control register fields */
#define CONTROL_M         0  /* MMU enable */
#define CONTROL_A         1  /* Alignment check enable */
#define CONTROL_C         2  /* Cacheability control, for data caching */
#define CONTROL_SA        3  /* Stack Alignment Check for EL1 */
#define CONTROL_SA0       4  /* Stack Alignment Check Enable for EL0 */
#define CONTROL_I         12 /* Instruction access Cacheability control */
#define CONTROL_E0E       24 /* Endianness of data accesses at EL0 */
#define CONTROL_EE        25 /* Endianness of data accesses at EL1 */
#define CONFIG_LOAD_ADDR        (0x80000UL)//(CONFIG_LOAD_ADDR)
#define CONFIG_EXEC_ADDR        (0xffff000000080000)//(CONFIG_LOAD_ADDR)

#define CONFIG_PAGE_SHIFT   (12)
#define CONFIG_PAGE_SIZE    (2 << CONFIG_PAGE_SHIFT)

// default stack size for user applications
#define CONFIG_STACK_PAGES (2)
#define CONFIG_STACK_SIZE (CONFIG_STACK_PAGES << CONFIG_PAGE_SHIFT)
.globl _start
_start:
	mrs	x0, mpidr_el1		
	and	x0, x0,#0xFF		// Check processor id
	cbz	x0, master		// Hang for all non-primary CPU
	b	proc_hang

proc_hang: 
	b 	proc_hang

master:
MRS X0,SCTLR_EL2
        ldr     x1 , =~(1 << CONTROL_M  | 1 << CONTROL_C | 1 << CONTROL_I)
        and x0,x0,x1
        ISB
	MSR SCTLR_EL2,X0
/* 配置SCTLR_EL2寄存器，关闭其中的EL2指令、数据cache以及MMU */
MRS X0,SCTLR_EL2
ldr     x1 , =~(1 << CONTROL_M  | 1 << CONTROL_C | 1 << CONTROL_I)
and x0,x0,x1
ISB
MSR SCTLR_EL2,X0


 /* 配置SCTLR_EL1寄存器，关闭其中的EL1指令、数据cache以及MMU */
       MRS X0,SCTLR_EL1
       ldr     x1 , =~(1 << CONTROL_M  | 1 << CONTROL_C | 1 << CONTROL_I)
       and x0,x0,x1
       ISB
       MSR SCTLR_EL1,X0
    /* 配置HCR_EL2寄存器，关闭el0以及el1的stage2机制 */
	MRS X0,HCR_EL2
        ldr     x1 , =~(1 << 0)
	and x0,x0,x1
        ldr     x1 , =(1 <<12)
	orr x0,x0,x1
	MSR HCR_EL2,X0          /* disable el0 el1 stage2  */


	bl __init_uart

	mrs x5, CurrentEL
	cmp x5, #CurrentEL_EL3
	b.eq el3_entry
	b el2_entry


el3_entry:
	eret

el2_entry:
	bl print_el

	/* The Execution state for EL1 is AArch64 */
	ldr x0, =HCR_HOST_NVHE_FLAGS
	msr hcr_el2, x0

	ldr x0, =SCTLR_VALUE_MMU_DISABLED
	msr sctlr_el1, x0

	ldr x0, =SPSR_EL1
	msr spsr_el2, x0

	adr x0, el1_entry
	msr elr_el2, x0

	eret

el1_entry:
	bl print_el

	ldr x5, =(3UL << 20);
	msr cpacr_el1, x5

        ldr     x5, =vectors
	ldr x2, =CONFIG_EXEC_ADDR
	sub x2, x5, x2
	ldr x3, =CONFIG_LOAD_ADDR
        add x5, x2, x3
	msr     vbar_el1, x5
	isb



	/* 设置EL1的堆栈以及EL2的堆栈 */
       bl get_idle_stack_x0_to_x3      /* 获取堆栈的虚拟地址 */
       ldr x2, = CONFIG_EXEC_ADDR /* 代码的执行地址（虚拟地址） */
       sub x2, x1, x2
       ldr x3, = CONFIG_LOAD_ADDR  /* 代码加载地址（物理地址） */
       add x1, x2 , x3                         /* 将x1转换位实际的物理地址 */
/*        msr sp_el1,x1 */                          /* 设置EL1的堆栈，准备进入EL1 */

       mov sp, x1                           /* 同时设置EL2的堆栈 */
       
    adr     x0, bss_begin
    adr     x1, bss_end
    sub     x1, x1, x0
    bl      memzero
   /* mov     sp, #LOW_MEMORY*/
    bl      kernel_main
    b       proc_hang               // should never come here

print_el:
	mov x10, x30

	/*
	   print EL
	 */
	adrp x0, el_string1
	add x0, x0, :lo12:el_string1
	bl put_string_uart

	mrs x5, CurrentEL
	/* get the currentEL value */
	lsr x2, x5, #2
	mov x0, #48
	add x0, x0, x2
	bl put_uart
	/* print the new line tab */
	mov x0, #10
	bl put_uart

	mov x30, x10
	ret



get_idle_stack_x0_to_x3:	/* X0:CPUID X1:STACK X2:STACK_SIZE */
	mov x0,#0				/* X0涓篊PU鐨処D锛宼empstack閲岄潰鍖呮嫭浜嗗洓涓牳鐨勫爢鏍堬紝鏍规嵁CPU鐨処D鏉ラ€夋嫨瀵瑰簲鐨勫爢鏍?*/
    mov x1, #0x3		/* 灞忚斀浣嶏紝cpu鍙湁4涓牳鎵€浠ュ€煎彧鑳戒负0,1,10,11 */
    and x0, x0, x1
	
    ldr x1, = tempstack /* 涓存椂鍒嗛厤鐨勬爤 */
    ldr x2, = CONFIG_STACK_SIZE
    mul x3, x0, x2
    add x1, x1, x3			/* 鑾峰彇瀵瑰簲鏍哥殑鏍堥《 */
    add x1, x1, x2			/* x1鎸囧悜鏍堝簳 */

	mrs		x4,spsel
	orr		x4,x4,#1
    msr     spsel, x4		/* 閫夋嫨sp_elx浣滀负鍫嗘爤鎸囬拡 */

	ret 
/* 濡傛灉褰撳墠4鏍革紝cpu_id = 0鍦ㄧ粡杩囦笂杩扮殑鍒嗛厤鍚庯紝浼氬舰鎴愪笅闈㈢殑鍒嗗竷銆備笅闈㈢殑idlestack绫讳技
-------- 浣庡湴鍧€ <- tempstack
|  8KB | for core0
-------- 
|  8KB | for core1
--------
|  8KB | for core2
--------
|  8KB | for core3
-------- 楂樺湴鍧€
*/

.section ".stack"
.global tempstack
//杩炵画鍒嗛厤杩欎箞澶х殑鍐呭瓨
tempstack:
#ifdef CONFIG_ENABLE_SMP
    .space (CONFIG_SMP_CORES * CONFIG_STACK_SIZE)  /* 4*8KB */
#else
    .space CONFIG_STACK_SIZE  /* 8KB */ 
#endif

.section ".idle_stack"
.global idlestack
//杩炵画鍒嗛厤杩欎箞澶х殑鍐呭瓨
idlestack:
#ifdef CONFIG_ENABLE_SMP
    .space (CONFIG_SMP_CORES * CONFIG_STACK_SIZE)  /* 4*8KB */
#else
    .space CONFIG_STACK_SIZE  /* 8KB */ 
#endif



	adr	x0, bss_begin
	adr	x1, bss_end
	sub	x1, x1, x0
	bl 	memzero
	/*identical mapping*/
#if 0
	bl create_page_table
	ldr x0, =ksram
	ldr x1, =ksdev
	ldr x2, =boot_end
	bl set_mmu
	
#endif

	mov	sp, #LOW_MEMORY 
	bl	kernel_main
	b 	proc_hang		// should never come here




set_mmu:
    ret
create_page_table:
    mov x25, x30
 

    mov x30, x25
    ret


