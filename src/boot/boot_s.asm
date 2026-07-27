; ==================================================================
; ESTÁGIO 2: Bootloader (Boot2)
; Localização: Setores 2 a 5 do Disco
; Endereço de Carga: 0x7E00
; ==================================================================
[ORG 0x7E00]
[BITS 16]

boot2_start:
    ; Exibe mensagem indicando que o Estágio 2 foi executado
    mov si, msg_boot2
    call imprimir_texto

    ; --------------------------------------------------------------
    ; Carregar o Kernel (Setor 6 em diante) para o endereço 0x8000
    ; --------------------------------------------------------------
    mov bx, 0x8000          ; Endereço de destino na RAM para o Kernel
    mov ah, 0x02            ; Serviço BIOS: Ler setores
    mov al, 15              ; Quantidade de setores a ler (espaço para o Kernel)
    mov ch, 0               ; Cilindro 0
    mov dh, 0               ; Cabeça 0
    mov cl, 6               ; Começa no Setor 6 (Setor 1 = Boot1, Setores 2-5 = Boot2)
    mov dl, 0x80            ; Primeiro disco rígido/drive principal

    int 0x13                ; Leitura de disco via BIOS
    jc erro_kernel          ; Se falhar, exibe mensagem de erro

    mov si, msg_sucesso
    call imprimir_texto

    ; --------------------------------------------------------------
    ; Salta para o ponto de entrada do Kernel
    ; --------------------------------------------------------------
    jmp 0x8000

erro_kernel:
    mov si, msg_erro_k
    call imprimir_texto
    cli
    hlt

; ------------------------------------------------------------------
; Rotina de impressão de texto em Modo Real
; ------------------------------------------------------------------
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

; ------------------------------------------------------------------
; Dados do Boot2
; ------------------------------------------------------------------
msg_boot2:   db '[Boot2] Estagio 2 iniciado em 0x7E00. Lendo Kernel...', 0x0D, 0x0A, 0
msg_sucesso: db '[Boot2] Kernel carregado! Transferindo controle para 0x8000...', 0x0D, 0x0A, 0
msg_erro_k:  db '[Erro] Falha ao carregar o Kernel do disco!', 0x0D, 0x0A, 0

; Preenche até o final do setor para garantir tamanho fixo
times 2048 - ($ - $$) db 0  ; Ocupa exatamente 4 setores (2048 bytes)