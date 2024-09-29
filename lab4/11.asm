;11.asm
format ELF64

public _start
section '.bss' writable
msg rb 255
tie_msg db "Tie", 0xA, 0
section '.code' executable

include 'printlib.asm'

_start:
    xor rbx, rbx
    mov rsi, msg
    call input_keyboard
    call str_number
    mov rcx, rax

    .loop:
        mov rsi, msg
        call input_keyboard
        call str_number
        
        cmp rax, 0
        jne .if
        dec rbx
        jmp .else
        .if:
        inc rbx
        .else:
        dec rcx
        cmp rcx, 0
        jne .loop

    mov rax, rbx
    cmp rax, 0
    je .tie
    jg .positive
    jl .negative
    
    .tie:
    mov rsi, tie_msg
    call print_str
    jmp .exit

    .positive:
    mov rax, '1'
    call print_symbol
    call print_newline
    jmp .exit

    .negative:
    mov rax, '0'
    call print_symbol
    call print_newline


    .exit:
    call exit

