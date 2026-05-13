void printl(const char *str){
   unsigned short *vmemory = (unsigned short *)0xb8000;
   unsigned char color = 0x0f;
   for (int i=0; str[1] != '\0'; i++) {
      vmemory[i] = (unsigned short)str[i] | (unsigned short)color << 8;
   }
}