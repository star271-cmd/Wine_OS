ENTRY(_start)
SECTIONS
{
    . = 0x8000; /* Define o endereço base do Kernel na RAM */

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
    }
}