; ==================================================================
; ESTÁGIO 3: Menu Interativo (Carregado em 0x8000)
; ==================================================================
[ORG 0x8000]
[BITS 16]

estagio3_inicio:
    ; Exibe o menu inicial
    mov si, menu_texto
    call imprimir_texto

menu_loop:
    ; Aguarda uma tecla ser pressionada (AH = 0x00, INT 0x16)
    mov ah, 0x00
    int 0x16            ; O caractere lido fica salvo no registrador AL

    ; Verifica a opção digitada
    cmp al, '1'
    je opcao_1

    cmp al, '2'
    je opcao_2

    cmp al, '3'
    je opcao_3

    ; Se digitar qualquer outra coisa, ignora e continua esperando
    jmp menu_loop

; ------------------------------------------------------------------
; Ações das Opções do Menu
; ------------------------------------------------------------------
opcao_1:
    mov si, msg_opcao1
    call imprimir_texto
    jmp menu_loop

opcao_2:
    mov si, msg_opcao2
    call imprimir_texto
    jmp menu_loop

opcao_3:
    mov si, msg_opcao3
    call imprimir_texto
    cli
    hlt                 ; Desliga a CPU até o próximo reboot
    jmp opcao_3

; ------------------------------------------------------------------
; Rotina de Impressão de Texto
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
; Mensagens e Dados
; ------------------------------------------------------------------
menu_texto: 
    db 0x0D, 0x0A
    db '=== MENU PRINCIPAL (ESTAGIO 3) ===', 0x0D, 0x0A
    db '1. Exibir mensagem especial', 0x0D, 0x0A
    db '2. Limpar a tela', 0x0D, 0x0A
    db '3. Desligar/Parar o sistema', 0x0D, 0x0A
    db 'Escolha uma opcao: ', 0

msg_opcao1:
    db 0x0D, 0x0A, '-> Voce escolheu a Opcao 1! Ola do Estagio 3.', 0x0D, 0x0A, 0

msg_opcao2:
    ; Limpa a tela antes de mostrar a mensagem
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    db 0x0D, 0x0A, '-> Tela limpa com sucesso!', 0x0D, 0x0A, 0

msg_opcao3:
    db 0x0D, 0x0A, '-> Sistema finalizado (HLT).', 0x0D, 0x0A, 0
