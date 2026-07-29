//#ifndef VGA_H
//#define VGA_H

//typedef unsigned char uint8_t;
//typedef unsigned short uint16_t;

//#define COR_PRETO 0
//#define COR_VERDE 2
//#define COR_VERMELHO 4
//#define COR_BRANCO 15

//void limpar_tela();
//void imprimir_caractere(char c, uint8_t cor_texto, uint8_t cor_fundo);
//void imprimir_string(const char* str, uint8_t cor_texto, uint8_t cor_fundo);
//int get_cursor_x();
//int get_cursor_y();
//void set_cursor_x(int x);

//#endif
#ifndef VGA_H
#define VGA_H
#include "stdint.h"
#define VGA_ADDRESS 0xb8000
#define COLOR 0x07

void setcolor(uint8_t color, uint8_t target);
void printl(const char *str);
void drawsquare(uint32_t x, uint32_t y, uint32_t width, uint32_t height, uint8_t color, int fill);
void drawcircle(uint32_t xc, uint32_t yc, uint32_t r, uint8_t color);

#endif