; ==================================================================
; ESTÁGIO 1: Bootloader MBR (512 bytes)
; Localização: Setor 1 do Disco
; Endereço de Carga: 0x7C00
; ==================================================================
[ORG 0x7C00]
[BITS 16]

boot_start:
    ; 1. Normaliza os registradores de segmento (DS, ES, SS) para 0x0000
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; A pilha cresce para baixo a partir do endereço de carga

    ; 2. Salva o número do drive de boot passado pela BIOS (registrador DL)
    mov [drive_boot], dl

    ; 3. Limpa a tela definindo o modo de vídeo (80x25 texto, 16 cores)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; 4. Exibe mensagem de inicialização
    mov si, msg_carregando
    call imprimir_texto

    ; --------------------------------------------------------------
    ; 5. Carregar o Estágio 2 (Boot2.asm) do Disco para a RAM
    ; --------------------------------------------------------------
    mov bx, 0x7E00          ; Endereço de destino na RAM (logo após o MBR)
    mov ah, 0x02            ; Serviço da BIOS: Ler Setores do Disco
    mov al, 4               ; Lê 4 setores (2048 bytes para o Boot2)
    mov ch, 0               ; Cilindro 0
    mov dh, 0               ; Cabeça (Head) 0
    mov cl, 2               ; Setor 2 (O Setor 1 é este próprio arquivo MBR)
    mov dl, [drive_boot]    ; Drive de onde inicializamos

    int 0x13                ; Executa a leitura via BIOS
    jc erro_leitura         ; Se a Carry Flag (CF) for 1, ocorreu erro de leitura

    ; --------------------------------------------------------------
    ; 6. Salto para o Estágio 2 (Boot2.asm)
    ; --------------------------------------------------------------
    jmp 0x7E00              ; Transfere o controle para o endereço 0x7E00

erro_leitura:
    mov si, msg_erro
    call imprimir_texto
    cli
    hlt

; ------------------------------------------------------------------
; Rotina auxiliar para impressão de strings na tela
; ------------------------------------------------------------------
imprimir_texto:
    mov ah, 0x0E            ; Teletipo da BIOS (escreve caractere e avança cursor)
.loop:
    lodsb                   ; Carrega o byte de [SI] em AL e incrementa SI
    cmp al, 0
    je .fim
    int 0x10
    jmp .loop
.fim:
    ret

; ------------------------------------------------------------------
; Dados
; ------------------------------------------------------------------
drive_boot:     db 0
msg_carregando: db '[Boot1] MBR iniciado. Carregando Boot2...', 0x0D, 0x0A, 0
msg_erro:       db '[Erro] Falha ao ler o disco!', 0x0D, 0x0A, 0

; ------------------------------------------------------------------
; Preenchimento do MBR e Assinatura de Boot
; ------------------------------------------------------------------
times 510 - ($ - $$) db 0   ; Preenche com zeros até atingir 510 bytes
dw 0xAA55                   ; Assinatura mágica de boot (2 bytes finais)