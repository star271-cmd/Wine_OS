; ==================================================================
; ESTÁGIO 2: Código Principal (Carregado em 0x7E00)
; ==================================================================
[ORG 0x7E00]
[BITS 16]

estagio2_inicio:
    mov si, msg_sucesso
    call imprimir_texto

    ; Aqui você pode adicionar funções mais complexas:
    ; - Mudar para Modo Protegido (32 bits)
    ; - Carregar o Kernel do seu sistema operacional
    ; - Detectar a memória RAM via BIOS (int 0x15, E820)

loop_infinito:
    cli
    hlt
    jmp loop_infinito

imprimir_texto:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .fim
    int 0x10
    jmp .loop
.fim:
    ret

msg_sucesso: db 'Estagio 2: Executado com sucesso a partir de 0x7E00!', 0x0D, 0x0A, 0