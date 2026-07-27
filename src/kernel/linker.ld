/*
 * Script do Linker para o Kernel
 * Ponto de entrada: _start (definido no src/kernel/boot.asm)
 */

ENTRY(_start)

SECTIONS
{
    /* Define o endereço de memória base onde o Kernel será carregado */
    . = 0x8000;

    /* Seção de Código Instruções Executáveis */
    .text : ALIGN(4K)
    {
        *(.text)
    }

    /* Seção de Dados Somente Leitura (Strings constantes, etc.) */
    .rodata : ALIGN(4K)
    {
        *(.rodata)
    }

    /* Seção de Dados Inicializados (Variáveis globais) */
    .data : ALIGN(4K)
    {
        *(.data)
    }

    /* Seção de Dados Não Inicializados */
    .bss : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }
}