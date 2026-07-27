; ==================================================================
; ESTÁGIO 1: Bootloader MBR (Salvo no Setor 1 do disco)
; ==================================================================
[ORG 0x7C00]
[BITS 16]

inicio:
    ; Configuração dos registradores de segmento
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Pilha cresce para baixo a partir de 0x7C00

    ; Guarda o drive de boot passado pela BIOS em DL (ex: 0x80 para HDD/USB)
    mov [drive_boot], dl

    ; Limpa a tela
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    mov si, msg_carregando
    call imprimir_texto

    ; --------------------------------------------------------------
    ; Carregar o Estágio 2 do Disco para a RAM
    ; --------------------------------------------------------------
    mov bx, 0x7E00      ; Endereço de destino na RAM (logo após o MBR)
    mov ah, 0x02        ; Função BIOS: Ler setores
    mov al, 2           ; Quantidade de setores para ler (ex: 2 setores = 1024 bytes)
    mov ch, 0           ; Cilindro 0
    mov dh, 0           ; Cabeça 0
    mov cl, 2           ; Começa no Setor 2 (o Setor 1 é o MBR)
    mov dl, [drive_boot]; Drive de onde fizemos o boot

    int 0x13            ; Interrupção de disco da BIOS
    jc erro_leitura     ; Se houver erro de leitura (Carry Flag = 1)

    ; --------------------------------------------------------------
    ; Saltar para o Estágio 2
    ; --------------------------------------------------------------
    jmp 0x7E00          ; Passa o controle para o código carregado em 0x7E00

erro_leitura:
    mov si, msg_erro
    call imprimir_texto
    cli
    hlt

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

; Dados do Estágio 1
drive_boot:     db 0
msg_carregando: db 'Estagio 1: Lendo o disco...', 0x0D, 0x0A, 0
msg_erro:       db 'Erro ao carregar o Estagio 2!', 0

; Preenchimento do MBR
times 510 - ($ - $$) db 0
dw 0xAA55