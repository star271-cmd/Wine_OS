// ==================================================================
// DEFINIÇÕES DE TIPOS E CONSTANTES
// ==================================================================
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Cores VGA
#define COLOR_BLACK 0
#define COLOR_WHITE 15
#define COLOR_GREEN 2

// Ponteiros globais de controle do terminal
volatile uint16_t* vga_buffer = (uint16_t*)VGA_ADDRESS;
int cursor_x = 0;
int cursor_y = 0;

// ==================================================================
// COMUNICAÇÃO DE HARDWARE (PORTAS I/O)
// ==================================================================
// Lê um byte de uma porta I/O (usado para ler o teclado)
static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

// ==================================================================
// DRIVER DE VÍDEO VGA
// ==================================================================
void limpar_tela() {
    uint16_t espaco_branco = (COLOR_WHITE << 8) | ' ';
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = espaco_branco;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void imprimir_caractere(char c, uint8_t cor) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else {
        int index = cursor_y * VGA_WIDTH + cursor_x;
        vga_buffer[index] = (cor << 8) | c;
        cursor_x++;
    }

    // Wrap de linha simples
    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }
}

void imprimir_string(const char* str, uint8_t cor) {
    while (*str) {
        imprimir_caractere(*str, cor);
        str++;
    }
}

// ==================================================================
// DRIVER DE TECLADO (Scan Codes PS/2 Simples)
// ==================================================================
char ler_tecla() {
    static const char scan_codes[128] = {
        0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
      '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
        0,  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
        0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
      '*',   0, ' '
    };

    while (1) {
        // Verifica se a porta 0x64 tem dados prontos
        if (inb(0x64) & 1) {
            uint8_t scancode = inb(0x60);
            // Se o bit 7 não estiver ativado, significa que a tecla foi pressionada (Key Down)
            if (!(scancode & 0x80)) {
                char c = scan_codes[scancode];
                if (c != 0) return c;
            }
        }
    }
}

// ==================================================================
// UTILITÁRIOS DE STRING
// ==================================================================
int comparar_strings(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

// ==================================================================
// KERNEL MAIN (PONTO DE ENTRADA DO C)
// ==================================================================
void kernel_main() {
    limpar_tela();

    imprimir_string("=========================================\n", COLOR_GREEN);
    imprimir_string("   Meu Kernel 64-bit Escrito em C!       \n", COLOR_GREEN);
    imprimir_string("=========================================\n\n", COLOR_GREEN);
    
    char buffer[64];
    int pos = 0;

    while (1) {
        imprimir_string("C-Kernel> ", COLOR_WHITE);
        pos = 0;

        while (1) {
            char c = ler_tecla();

            if (c == '\n') {
                buffer[pos] = '\0';
                imprimir_caractere('\n', COLOR_WHITE);
                break;
            } else if (c == '\b') { // Backspace
                if (pos > 0) {
                    pos--;
                    cursor_x--;
                    imprimir_caractere(' ', COLOR_WHITE);
                    cursor_x--;
                }
            } else if (pos < 63) {
                buffer[pos++] = c;
                imprimir_caractere(c, COLOR_WHITE);
            }
        }

        // Processa Comandos
        if (comparar_strings(buffer, "ajuda") == 0) {
            imprimir_string("Comandos: ajuda, limpar, sobre\n", COLOR_WHITE);
        } else if (comparar_strings(buffer, "limpar") == 0) {
            limpar_tela();
        } else if (comparar_strings(buffer, "sobre") == 0) {
            imprimir_string("Kernel v1.0 compilado com GCC em Bare-Metal!\n", COLOR_WHITE);
        } else if (buffer[0] != '\0') {
            imprimir_string("Comando desconhecido.\n", COLOR_WHITE);
        }
    }
}