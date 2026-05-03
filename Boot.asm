[BITS 16]
[ORG 0x7c00]

init:
   xor ax, ax
   mov ds, ax
   mov ss, ax
   mov es, ax
   mov sp, 0x7c00

   mov bx, 0

   mov ah, 0x02
   mov al, 1
   mov ch, 0
   mov cl, 2
   mov dh, 0

   mov bx, 0x7e00

   int 0x13

   jc disk_error

   jmp 0x000:0x7e00

disk_error:
   jmp $

times 510-($-$$) db 0
dw 0xAA55
