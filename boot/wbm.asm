[BITS 16]
[ORG 0x7c00]

init:
   xor ax, ax
   mov es, ax
   mov ss, ax
   mov ds, ax
   mov sp, 0x7c00
   mov bx 0x7e00

print:
   mov ah, 0x0e
   int 0x10

disk_error:
   mov al, 'an error was been ocurred when tried to boot'
   call print
   hlt

jc disk_error


int 0x13