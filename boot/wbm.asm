[BITS 16]
[ORG 0x7c00]

xor ax, ax
mov es, ax
mov ss, ax
mov ds, ax
mov sp, 0x7c00
mov bx 0x7e00

print:
   int 0x10
   mov ah, 0x0e
   
mov ah, 0x02
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0

int 0x13