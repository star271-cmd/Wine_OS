; ==================================================================
; KERNEL 16-BITS - SHELL E COMANDOS
; Endereço de carregamento: 0x8000
; ==================================================================
[ORG 0x8000]
[BITS 16]

kernel_main:
    ; Configura os registradores de segmento
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Limpa a tela na inicialização
    call limpar_tela

    ; Mensagem de boas-vindas
    mov si, msg_welcome
    call imprimir_texto

prompt_loop:
    ; Exibe o prompt do shell (ex: "OS> ")
    mov si, msg_prompt
    call imprimir_texto

    ; Lê o comando digitado pelo usuário
    mov di, buffer_comando
    call ler_string

    ; Pula linha após o ENTER
    mov si, msg_newline
    call imprimir_texto

    ; Processa o comando lido
    call processar_comando

    jmp prompt_loop     ; Loop infinito do shell

; ------------------------------------------------------------------
; INTERPRETADOR DE COMANDOS
; ------------------------------------------------------------------
processar_comando:
    ; Se o buffer estiver vazio, ignora
    cmp byte [buffer_comando], 0
    je .fim

    ; Testa o comando: "ajuda"
    mov si, buffer_comando
    mov di, cmd_ajuda
    call comparar_strings
    je .exec_ajuda

    ; Testa o comando: "limpar"
    mov si, buffer_comando
    mov di, cmd_limpar
    call comparar_strings
    je .exec_limpar

    ; Testa o comando: "info"
    mov si, buffer_comando
    mov di, cmd_info
    call comparar_strings
    je .exec_info

    ; Testa o comando: "desligar"
    mov si, buffer_comando
    mov di, cmd_desligar
    call comparar_strings
    je .exec_desligar

    ; Se não reconheceu nenhum comando:
    mov si, msg_desconhecido
    call imprimir_texto
    jmp .fim

.exec_ajuda:
    mov si, msg_ajuda_txt
    call imprimir_texto
    jmp .fim

.exec_limpar:
    call limpar_tela
    jmp .fim

.exec_info:
    mov si, msg_info_txt
    call imprimir_texto
    jmp .fim

.exec_desligar:
    mov si, msg_desligando
    call imprimir_texto
    cli
    hlt                 ; Para o processador

.fim:
    ret

; ------------------------------------------------------------------
; ROTINAS DE E/S (ENTRADA E SAÍDA) E UTILITÁRIOS
; ------------------------------------------------------------------

; Imprime uma string terminada em 0 (SI = endereço da string)
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

; Lê uma linha do teclado até pressionar ENTER (DI = endereço do buffer)
ler_string:
    xor cx, cx          ; CX conta os caracteres digitados

.loop:
    mov ah, 0x00
    int 0x16            ; Aguarda tecla (AL = ASCII, AH = Scan Code)

    cmp al, 0x0D        ; Tecla ENTER?
    je .concluido

    cmp al, 0x08        ; Tecla BACKSPACE?
    je .backspace

    cmp cx, 63          ; Limite máximo do buffer (64 bytes)
    jge .loop

    ; Salva o caractere no buffer e exibe na tela
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop

.backspace:
    jcxz .loop          ; Se não tem nada digitado, ignora o backspace
    dec di
    dec cx
    mov byte [di], 0

    ; Apaga o caractere da tela (Volta, espaço, volta)
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop

.concluido:
    mov byte [di], 0    ; Adiciona o caractere nulo no final da string
    ret

; Compara duas strings terminadas em 0 (SI = String 1, DI = String 2)
; Retorna Zero Flag (ZF = 1) se forem iguais
comparar_strings:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .diferente
    cmp al, 0
    je .iguais
    inc si
    inc di
    jmp .loop
.diferente:
    mov al, 1
    cmp al, 0           ; Reseta a Zero Flag (ZF = 0)
    ret
.iguais:
    xor ax, ax          ; Ativa a Zero Flag (ZF = 1)
    ret

; Limpa a tela
limpar_tela:
    mov ah, 0x00
    mov al, 0x03        ; Redefine modo texto 80x25
    int 0x10
    ret

; ------------------------------------------------------------------
; VARIÁVEIS E DADOS
; ------------------------------------------------------------------
msg_welcome:      db '=========================================', 0x0D, 0x0A
                  db '   MeuOS Kernel v1.0 - Modo Real 16-bit  ', 0x0D, 0x0A
                  db '=========================================', 0x0D, 0x0A
                  db 'Digite "ajuda" para ver os comandos.', 0x0D, 0x0A, 0

msg_prompt:       db 0x0D, 0x0A, 'MeuOS> ', 0
msg_newline:      db 0x0D, 0x0A, 0
msg_desconhecido: db 'Comando nao reconhecido. Digite "ajuda".', 0x0D, 0x0A, 0
msg_desligando:   db 'Sistema desligado/suspenso com sucesso.', 0x0D, 0x0A, 0

; Textos das opções do menu
msg_ajuda_txt:    db 'Comandos disponiveis:', 0x0D, 0x0A
                  db '  ajuda    - Mostra esta lista de comandos', 0x0D, 0x0A
                  db '  limpar   - Limpa a tela do terminal', 0x0D, 0x0A
                  db '  info     - Exibe detalhes do sistema', 0x0D, 0x0A
                  db '  desligar - Encerra a execucao do Kernel', 0x0D, 0x0A, 0

msg_info_txt:     db 'Detalhes do Kernel:', 0x0D, 0x0A
                  db '  Arquitetura: x86 (16-bits Real Mode)', 0x0D, 0x0A
                  db '  Endereco Base: 0x8000', 0x0D, 0x0A
                  db '  E/S: Interrupcoes BIOS (INT 10h / INT 16h)', 0x0D, 0x0A, 0

; Nomes dos Comandos
cmd_ajuda:        db 'ajuda', 0
cmd_limpar:       db 'limpar', 0
cmd_info:         db 'info', 0
cmd_desligar:     db 'desligar', 0

; Buffer onde o comando do usuário é armazenado (64 bytes)
buffer_comando:   times 64 db 0