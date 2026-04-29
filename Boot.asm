[BITS 16]
[ORG 0x7c00]

init:
   mov ax, 0
   mov ds, ax
   mov ss, ax
   mov es, ax

   mov sp, 0x7c00

   mov si, 0

   mov bx, 0

   call print_loop

print_loop:
   mov cl, [msg+bx]

   call print

   inc bx

   cmp cl, 0
   jnz print_loop

print:
   mov ah, 0x0e
   mov al, cl
   int 0x10
   ret

times 510 - ($ - $$) db 0
dw 0xAA55
