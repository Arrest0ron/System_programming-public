
format ELF64

public _start
section '.bss' writable
msg rb 255

section '.code' executable

include 'printlib.asm'

_start:
    mov rsi, msg
    xor rax, rax
    call input_keyboard
    call str_number

    .iter1:
        mov rdi, rax
        call number_str
        call get_len
        call power10
        mov rbx, rax
        mov rax, rdi
        mul rdi
        div rbx
        mov rax, rdi

        cmp rdx, rdi
        jne .next

        
        call number_str
        call print_str
        call print_newline
 
        jmp .next

        .next:
            dec rax
            cmp rax, 0
            je .end
            jmp .iter1
        


    .end:
    call exit



; rdx  -> rax = 10^rdx
power10:
    push rbx
    push rdx
    mov rax, 1
    mov rbx, 10
    .loop:
        push rdx
        mul rbx
        pop rdx
        dec rdx
        cmp rdx, 0
        jne .loop
    pop rdx
    pop rbx

    ret
        
