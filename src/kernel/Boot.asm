; ==================================================================
; KERNEL ENTRY POINT (Entrada do Kernel)
; Endereço de Carga: 0x8000
; ==================================================================
[BITS 16]                   ; Iniciamos recebendo o controle em Modo Real 16-bit
[EXTERN kernel_main]       ; Declara que a função kernel_main está no arquivo C

global _start
_start:
    ; 1. Garante a configuração correta dos registradores de segmento
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; 2. Define o ponteiro de pilha (Stack Pointer) em uma área segura de memória
    mov sp, 0x9000

    ; 3. Chama a função principal do Kernel escrita em C!
    call kernel_main

    ; 4. Caso a função em C termine/retorne, trava a CPU em loop
kernel_halt:
    cli                     ; Desabilita interrupções de hardware
    hlt                     ; Suspende o processador
    jmp kernel_halt         ; Garante que não execute lixo de memória