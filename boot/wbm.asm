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
   mov al, [si]
   mov ah, 0x0e
   int 0x10

int 0x13

disk_error:
   mov si, 'an error was been ocurred when tried to boot'
   call print
   hlt

mov ah, 0x02
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, [disk_drive]
halt:
   jmp halt

jc disk_error

times 510 - ($ - $$) db 0
dw 0xAA55