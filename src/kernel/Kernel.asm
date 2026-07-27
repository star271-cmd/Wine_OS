// ==================================================================
// KERNEL PRINCIPAL EM C
// Endereço de carga: 0x8000
// ==================================================================

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Cores VGA (4 bits para cor de fundo, 4 bits para cor do texto)
#define COR_PRETO 0
#define COR_VERDE 2
#define COR_VERMELHO 4
#define COR_BRANCO 15

volatile uint16_t* vga_buffer = (uint16_t*)VGA_ADDRESS;
int cursor_x = 0;
int cursor_y = 0;

// ------------------------------------------------------------------
// COMUNICAÇÃO DE BAIXO NÍVEL COM PORTAS I/O
// ------------------------------------------------------------------
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// ------------------------------------------------------------------
// DRIVER DE VÍDEO VGA
// ------------------------------------------------------------------
void limpar_tela() {
    uint16_t espaco = (COR_PRETO << 12) | (COR_BRANCO << 8) | ' ';
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = espaco;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void imprimir_caractere(char c, uint8_t cor_texto, uint8_t cor_fundo) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else {
        int index = cursor_y * VGA_WIDTH + cursor_x;
        vga_buffer[index] = (cor_fundo << 12) | (cor_texto << 8) | c;
        cursor_x++;
    }

    // Quebra de linha automática ao atingir a borda direita
    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }
}

void imprimir_string(const char* str, uint8_t cor_texto, uint8_t cor_fundo) {
    while (*str) {
        imprimir_caractere(*str, cor_texto, cor_fundo);
        str++;
    }
}

// ------------------------------------------------------------------
// DRIVER DE TECLADO (Scan Codes PS/2)
// ------------------------------------------------------------------
char ler_tecla() {
    static const char tabela_scancodes[128] = {
        0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
      '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
        0,  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
        0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
      '*',   0, ' '
    };

    while (1) {
        // Aguarda o buffer da porta 0x64 sinalizar que há dados disponíveis
        if (inb(0x64) & 1) {
            uint8_t scancode = inb(0x60);
            // Ignora o evento de soltar a tecla (bit 7 setado)
            if (!(scancode & 0x80)) {
                char c = tabela_scancodes[scancode];
                if (c != 0) return c;
            }
        }
    }
}

// ------------------------------------------------------------------
// UTILITÁRIOS DE STRING
// ------------------------------------------------------------------
int comparar_strings(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

// ------------------------------------------------------------------
// PONTO DE ENTRADA DO KERNEL (Chamado pelo src/kernel/boot.asm)
// ------------------------------------------------------------------
void kernel_main() {
    limpar_tela();

    imprimir_string("=========================================\n", COR_VERDE, COR_PRETO);
    imprimir_string("        MeuOS Kernel Escrito em C!       \n", COR_VERDE, COR_PRETO);
    imprimir_string("=========================================\n\n", COR_VERDE, COR_PRETO);
    imprimir_string("Digite 'ajuda' para listar os comandos.\n\n", COR_BRANCO, COR_PRETO);

    char buffer[64];
    int pos = 0;

    while (1) {
        imprimir_string("MeuOS> ", COR_VERDE, COR_PRETO);
        pos = 0;

        while (1) {
            char c = ler_tecla();

            if (c == '\n') {
                buffer[pos] = '\0';
                imprimir_caractere('\n', COR_BRANCO, COR_PRETO);
                break;
            } else if (c == '\b') { // Trata o Backspace
                if (pos > 0) {
                    pos--;
                    cursor_x--;
                    imprimir_caractere(' ', COR_BRANCO, COR_PRETO);
                    cursor_x--;
                }
            } else if (pos < 63) {
                buffer[pos++] = c;
                imprimir_caractere(c, COR_BRANCO, COR_PRETO);
            }
        }

        // --- Processamento dos Comandos ---
        if (comparar_strings(buffer, "ajuda") == 0) {
            imprimir_string("Comandos disponiveis: ajuda, limpar, sobre\n\n", COR_BRANCO, COR_PRETO);
        } else if (comparar_strings(buffer, "limpar") == 0) {
            limpar_tela();
        } else if (comparar_strings(buffer, "sobre") == 0) {
            imprimir_string("MeuOS v1.0 - Compilado em Bare-Metal sem C Standard Library.\n\n", COR_BRANCO, COR_PRETO);
        } else if (buffer[0] != '\0') {
            imprimir_string("Comando nao reconhecido. Digite 'ajuda'.\n\n", COR_VERMELHO, COR_PRETO);
        }
    }
}