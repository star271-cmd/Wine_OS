#ifndef VGA_H
#define VGA_H
#define VGA_ADDRESS 0xb8000
#define COLOR 0x07

void setcolor(color, target);
void printl(const char *str);
void drawsquare(int x, int y, int width, int height, unsigned char color, int fill);
void drawcircle(int xc, int yc, int r, unsigned char color);

#endif