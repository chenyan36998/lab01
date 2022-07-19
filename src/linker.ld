SECTIONS
{
	. = 0xffff000000080000,
	.text.boot : { *(.text.boot) }
	.text : { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }
	. = ALIGN(0x8);
	. = ALIGN(2<<12);
	.idle_stack :{
        *.o(.idle_stack)    
        }
	. = ALIGN(2<<12);
        k_stack_start = .;
        .stack : 
   	{
          *(.stack);              
     }
     k_stack_end = .;
     . = ALIGN(2<<12);

	bss_begin = .;
	.bss : { *(.bss*) } 
	bss_end = .;
	
	. = ALIGN(4096);
	init_pg_dir = .;
	. += 4096;
}
