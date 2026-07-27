; Fragmento do stage2.asm
[ORG 0x7E00]
[BITS 16]

    ; Carrega o Estágio 3 (Setor 3 do disco) para o endereço 0x8000
    mov bx, 0x8000      ; Endereço de memória de destino
    mov ah, 0x02        ; Função de leitura da BIOS
    mov al, 1           ; Quantidade de setores (1 setor)
    mov ch, 0
    mov dh, 0
    mov cl, 3           ; Setor 3 do disco
    mov dl, [0x7C00 + drive_boot_offset] ; Ou passe o drive salvo no stage1

    int 0x13
    
    ; Salta para o Estágio 3
    jmp 0x8000