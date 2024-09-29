format ELF64

public _start
section '.bss' writable
msg rb 255
section '.code' executable

include 'printlib.asm'
_start:
   mov rax, 0
   mov rdi, 0
   mov rsi, msg
   mov rdx, 255
   syscall

   xor rdx, rdx
   xor rax, rax
.loop:
   mov al, [msg+rdx]
   cmp rax, 0
   je .next
   inc rdx
   jmp .loop
.next:
   mov rax, 1
   mov rdi, 1
   mov rsi, msg
   syscall

   mov rax, 60
   mov rdi, 0
   syscall