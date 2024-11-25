

format ELF64

public _start

section '.data' writable
hello db "Hello, I've been executed once more!", 0xA, 0

section '.code' executable
include 'func.asm'

_start:
mov rsi, hello
call print_str
    pop rcx
    xor rax, rax
    .iter:
        cmp rcx, rax
        je .next
        mov rsi,[rsp+8*rax]
        call print_str
        call new_line
        inc rax
    jmp .iter
    .next:
        call exit

