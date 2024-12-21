format elf64

public _start

include 'func.asm'
section '.data' writable
buf64 rb 64
pid rq 1
status rd 1
args rq 7
IN_FILE db "SOURCE", 0
OUT_FILE db "DESTINATION", 0
N1 db "5",0
N2 db "3",0
msg_end db "Process ended", 0xA, 0
	
section '.text' executable
_start:	
mlp:
    mov rsi, buf64
    call input_keyboard
    mov rax, 57
    syscall
    cmp rax, 0
    jne waiter
    mov [args], buf64
    mov [args+8], N1
    mov [args+16], N2
    mov [args+24], IN_FILE
    mov [args+32], OUT_FILE
    mov [args+40], 0
    mov rsi, args
    mov rdi, buf64
    mov rax, 59
    syscall
call exit

waiter:
    mov rsi, status
    mov rdi, -1
    mov rdx, 0
    mov r10, 0
    mov rax, 61
    syscall
    mov rsi, msg_end
    call print_str
    jmp mlp