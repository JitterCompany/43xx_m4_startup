
INCLUDE "link.ld"

ENTRY(ResetISR)

SECTIONS
{

    /* MAIN TEXT SECTION */    
    .text : ALIGN(4)
    {
        FILL(0xff)
        __vectors_start__ = ABSOLUTE(.) ;
        KEEP(*(.isr_vector))

        /* Meta data, e.g. firmware version may be stored here.
         * This place right after the isr_vector is chosen because the
         * memory address is very predictable / stable across different builds.
         * This is an advantage for bootloaders etc.
         */
        __meta_begin__ = ABSOLUTE(.);
        . = ALIGN(4) ;
        KEEP(*(.meta))
		__meta_end__ = ABSOLUTE(.);
        
        /* Global Section Table */
        . = ALIGN(4) ;
        __section_table_start = .;
        __data_section_table = .;
        LONG(LOADADDR(.data));
        LONG(    ADDR(.data));
        LONG(  SIZEOF(.data));
        __data_section_table_end = .;
        __bss_section_table = .;
        LONG(    ADDR(.bss));
        LONG(  SIZEOF(.bss));
        __bss_section_table_end = .;
        __section_table_end = . ;
        /* End of Global Section Table */
        

        *(.after_vectors*)
        
    } >Flash_M4
    
    .text : ALIGN(4)    
    {
         *(.text*)
        *(.rodata .rodata.* .constdata .constdata.*)
        . = ALIGN(4);
        
    } > Flash_M4

    /*
     * for exception handling/unwind - some Newlib functions (in common
     * with C++ and STDC++) use this. 
     */
    .ARM.extab : ALIGN(4)
    {
    	*(.ARM.extab* .gnu.linkonce.armextab.*)
    } > Flash_M4
    __exidx_start = .;
    
    .ARM.exidx : ALIGN(4)
    {
    	*(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > Flash_M4
    __exidx_end = .;
    
    _etext = .;
        

    /* MAIN DATA SECTION */

	/* Main DATA section (RAM_M4) */
	.data : ALIGN(4)
	{
	   FILL(0xff)
	   _data = . ;
	   *(vtable)
	   *(.data*)
	   . = ALIGN(4) ;
	   _edata = . ;
	} > RAM_M4 AT>Flash_M4

    /* MAIN BSS SECTION */
    .bss : ALIGN(4)
    {
        _bss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4) ;
        _ebss = .;
        PROVIDE(end = .);
    } > RAM_M4
        
    
    PROVIDE(_pvHeapStart = .);
    PROVIDE(_vStackTop = __top_RAM_M4 - 0);

    PROVIDE(__valid_user_code_checksum = 0 - 
        (_vStackTop 
        + (ResetISR + 1) 
        + (NMI_Handler + 1) 
        + (HardFault_Handler + 1)
        + (MemManage_Handler + 1)
        + (BusFault_Handler + 1)
        + (UsageFault_Handler + 1)
        )
    );
}
