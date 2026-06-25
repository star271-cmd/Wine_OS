#include vga.h
#include audio.h

int kmain(){
   pruntl("BATI foundation(C)2026-2027");
   try:
      read(0, 1, 2, 1);
   exept:
      printl("Can't read the hard disk - 0x0001")
   printl("Welcome to Wine");
   printl("C:/Computer/home/user/admin>");
   return 0;
};