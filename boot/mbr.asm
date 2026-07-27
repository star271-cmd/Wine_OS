[ORG 0x7C00]
[BITS 16]

inicio:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Guardar o drive de boot (DL)
    mov [drive_boot], dl

    ; Carrega 15 setores (nosso código de 64 bits) do disco para 0x7E00
    mov bx, 0x7E00
    mov ah, 0x02
    mov al, 15          ; Quantidade de setores a ler
    mov ch, 0
    mov dh, 0
    mov cl, 2           ; Setor 2
    mov dl, [drive_boot]
    int 0x13
    jc erro_disco

    ; Salta para o carregador de 64 bits que está em 0x7E00
    jmp 0x7E00

erro_disco:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    cli
    hlt

drive_boot: db 0

times 510 - ($ - $$) db 0
dw 0xAA55