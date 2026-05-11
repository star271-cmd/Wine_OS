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