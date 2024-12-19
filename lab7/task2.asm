format ELF64

include '/workspaces/System_programming/Lab_5/func.asm'

public _start

arrlen = 621
flags = 2147585792

section '.bss' writable
array rb arrlen
buffer rb 10
stack1 rq 4096
f db "/dev/random", 0
    
section '.text' executable
_start:
mov rax, 2
mov rdi, f
mov rsi, 0o
syscall
mov r8, rax
mov rax, 0
mov rdi, r8
mov rsi, array
mov rdx, arrlen
syscall
mov rax, 3
mov rdi, r8
syscall
call sort

mov rax, 56
mov rdi, flags
mov rsi, 4096
add rsi, stack1
syscall

cmp rax, 0
je .primes
    
mov rax, 61
mov rdi, -1
mov rdx, 0
mov r10, 0
syscall

call input_keyboard

mov rax, 56
mov rdi, flags
mov rsi, 4096
add rsi, stack1
syscall

cmp rax, 0
je .quantile
    
mov rax, 61
mov rdi, -1
mov rdx, 0
mov r10, 0
syscall

call input_keyboard

mov rax, 56
mov rdi, flags
mov rsi, 4096
add rsi, stack1
syscall

cmp rax, 0
je .median
    
mov rax, 61
mov rdi, -1
mov rdx, 0
mov r10, 0
syscall

call input_keyboard

mov rax, 56
mov rdi, flags
mov rsi, 4096
add rsi, stack1
syscall

cmp rax, 0
je .fifth
    
mov rax, 61
mov rdi, -1
mov rdx, 0
mov r10, 0
syscall

call exit

.fifth:
xor rax, rax
mov al, [array+5]
mov rsi, buffer
call number_str
call print_str
call new_line
call exit

.median:
mov rax, arrlen
mov rbx, 2
div rbx
mov bl, [array+rax]
mov rax, rbx
mov rsi, buffer
call number_str
call print_str
call new_line
call exit

.primes:
xor r8, r8
mov r9, array
add r9, arrlen
mov rsi, array
xor rbx, rbx

.count:
cmp rsi, r9
jnl .next
mov bl, [rsi]
cmp bl, 1
je .not_prime
mov rcx, 2

.prime_check:
cmp rcx, rbx
je .is_prime
mov rax, rbx
xor rdx, rdx
div rcx
cmp rdx, 0
je .not_prime
inc rcx
jmp .prime_check
            
.is_prime:
inc r8

.not_prime:
inc rsi
jmp .count
        
.next:
mov rax, r8
mov rsi, buffer
call number_str
call print_str
call new_line
call exit

.quantile:
mov rax, arrlen
mov rbx, 4
div rbx
mov rbx, arrlen-1
sub rbx, rax
xor rax, rax
mov al, [array+rbx]
mov rsi, buffer
call number_str
call print_str
call new_line
call exit

sort:
xor r11, r11

.sel_loop:
mov r12, r11
mov r10, r11
inc r10

.inner_loop:
xor rax, rax
mov al, [array+r12]
cmp [array+r10], al
jae .cont
mov r12, r10
.cont:
inc r10
cmp r10, arrlen
jl .inner_loop

xor rax, rax
xor rbx, rbx
mov bl, [array+r11]
mov al, [array+r12]
mov [array+r11], al
mov [array+r12], bl
inc r11
cmp r11, arrlen-1
jl .sel_loop

ret