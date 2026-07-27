[ORG 0x7E00]
[BITS 16]

setup_16:
    ; 1. Desabilita interrupções da BIOS
    cli

    ; 2. Configura as Tabelas de Paginação simples (Identity Paging de 2MB)
    ; L4 em 0x1000, L3 em 0x2000, L2 em 0x3000
    mov edi, 0x1000
    mov cr3, edi        ; Aponta CR3 para o PML4

    ; Zerar 12KB de memória para as tabelas (0x1000 até 0x4000)
    xor eax, eax
    mov ecx, 3072
    rep stosd

    ; Configurar PML4 -> PDPT -> Page Directory
    mov dword [0x1000], 0x2003 ; PML4E[0] -> PDPT (Present + Writable)
    mov dword [0x2000], 0x3003 ; PDPTE[0] -> PD (Present + Writable)
    mov dword [0x3000], 0x0083 ; PDE[0] -> 0x00000000 (Page Size 2MB + Present + Writable)

    ; 3. Ativar PAE (Physical Address Extension) no CR4
    mov eax, cr4
    or eax, 1 << 5      ; Bit 5 = PAE
    mov cr4, eax

    ; 4. Ativar Long Mode no MSR EFER (Extended Feature Enable Register)
    mov ecx, 0xC0000080 ; Endereço do MSR EFER
    rdmsr
    or eax, 1 << 8      ; Bit 8 = LME (Long Mode Enable)
    wrmsr

    ; 5. Ativar Paginação (PG) e Modo Protegido (PE) no CR0
    mov eax, cr0
    or eax, (1 << 31) | (1 << 0) ; Bit 31 = PG, Bit 0 = PE
    mov cr0, eax

    ; 6. Carregar a GDT de 64 bits
    lgdt [gdt64_descriptor]

    ; 7. Far Jump para código de 64 bits (Atualiza CS)
    jmp 0x08:kernel64_entry

; ------------------------------------------------------------------
; GDT (Global Descriptor Table) de 64 bits
; ------------------------------------------------------------------
gdt64:
    dq 0 ; Descritor Nulo
gdt64_code:
    ; Code Segment: Executable, Readable, 64-bit Long Mode (Bit 53 setado)
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
gdt64_data:
    ; Data Segment: Writable
    dq (1<<41) | (1<<44) | (1<<47)

gdt64_descriptor:
    dw $ - gdt64 - 1
    dd gdt64

; ==================================================================
; CÓDIGO DO KERNEL DE 64 BITS
; ==================================================================
[BITS 64]
kernel64_entry:
    ; Atualiza registradores de segmento
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Limpa a memória de vídeo VGA (0xB8000) escrevendo diretamente na RAM
    mov edi, 0xB8000
    mov rax, 0x0F200F200F200F20 ; Espaços em branco com texto branco
    mov ecx, 500                ; Limpa 80x25 caracteres
    rep stosq

    ; Imprime mensagem direto no Buffer de Vídeo VGA
    mov rsi, msg_kernel64
    mov rdi, 0xB8000
    call escrever_vga64

    ; Loop interativo simples via teclado
shell_64:
    hlt
    jmp shell_64

; Função para escrever texto no buffer VGA em 64 bits
escrever_vga64:
    mov ah, 0x0F        ; Cor: Texto Branco, Fundo Preto
.loop:
    lodsb
    cmp al, 0
    je .fim
    mov [rdi], ax
    add rdi, 2
    jmp .loop
.fim:
    ret

msg_kernel64: db 'Kernel de 64-Bits rodando com sucesso no Modo Longo!', 0

; Preenchimento do restante do arquivo para ocupar vários setores
times 4096 - ($ - $$) db 0