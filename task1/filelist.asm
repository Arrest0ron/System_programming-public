format elf64
public _start

include 'printlib.asm'


section '.data' writable
BIGGER db "My number is smaller", 0xA, 0
LOWER db "My number is bigger", 0xA, 0
TRUE_MSG db "SUCCESS!", 0xA, 0
REAL db "The number in question: ", 0
f  db "/dev/urandom",0


section '.bss' writable
buf64 rb 64
  number rq 1
  place rb 100
MAX dq ?
MIN dq ?
RANDOM dq ?

section '.text' executable

_start:
    pop rcx 
    pop rcx
    xor rcx, rcx
    xor rax, rax

    pop rsi
    call str_number

    mov [MIN], rax
    pop rsi
    call str_number
    inc rax
    mov [MAX], rax


   mov rdi, f
   mov rax, 2 
   mov rsi, 0o
   syscall 
   cmp rax, 0 
   jl .l1 
   mov r8, rax

   mov rax, 0 ;
   mov rdi, r8
   mov rsi, number
   mov rdx, 1
   syscall
   mov rax, [MAX]
   sub rax, [MIN]
   mov rcx, rax ;rcx=5
   mov rax, [number] ;rax = rand
   xor rdx, rdx

   div rcx
   mov rax, rdx
   add rax, [MIN]
   mov [RANDOM], rax

   mov rcx, 3
    .att:

    mov rsi, buf64
   call input_keyboard
    call str_number
    cmp [RANDOM], rax
    je .true
    cmp [RANDOM], rax
    jl .bigger
    cmp [RANDOM], rax
    jg .lower
    .next:
    dec rcx
    cmp rcx, 0
    jne .att

    mov rsi, REAL
    call print_str
    mov rax, [RANDOM]
    call number_str
    call print_str
    call print_newline

    jmp .close

    




    .true:
     mov rsi, TRUE_MSG
         call print_str
     jmp .close
    .bigger:
    mov rsi, BIGGER
        call print_str
    jmp .next
    .lower:
    mov rsi, LOWER
    call print_str
    jmp .next


.close:
   mov rax, 3
   mov rdi, r8
   syscall


.l1:
  call exit
