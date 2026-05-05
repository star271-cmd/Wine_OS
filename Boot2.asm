[BITS 16]
cli; clear interrupt flag
lgdt [gdt_descriptor]

mov eax, cr0
or eax, 1
mov cr0, eax

jmp 08h:clear_pipe

[BITS 32]
clear_pipe:
  mov ax, 10h
  mov ds, ax
  mov ss, ax
