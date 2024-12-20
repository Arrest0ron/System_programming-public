;;clone_2.asm

format elf64
public _start
include 'func.asm'
include 'asm_array.asm'
THREAD_FLAGS=2147585792


section '.data' writable


list dq 0
N dq 0
; int_str db "Введите число N: ",0
end_str db "Нажмите enter, чтобы вывести результат",0
section '.bss' writable

stack_1 rq 4096 
stack_2 rq 4096

buffer rb 100

section '.text' executable

_start:
mov rsi, [rsp+16]
call str_number

; mov rsi, int_str
; call print_str
  ; mov rsi, buffer
  ; call input_keyboard
  ; call str_number
  mov [N], rax
  mov rdi, [N]
  call create_array
  mov [list], rax
  mov rdi, rax
  mov rax, [N]
  call filler
  mov rax, [N]
  ; call printer
  

   ;;Запускаем первый тред
   mov rdi, THREAD_FLAGS
   mov rsi, 4096
   add rsi, stack_1
   mov rax, 56
   syscall
   cmp rax,0
   je thread_1
   
   ;;Запускаем второй тред
   mov rdi, THREAD_FLAGS
   mov rsi, 4096
   add rsi, stack_2
   mov rax, 56
   syscall
   cmp rax,0
   je thread_2
   
   ;;Ждем
   mov rsi, end_str
   call print_str
   call input_keyboard
   
   ;;Печатаем результаты

    mov rax, [N]
    mov rdi, [list]
    call printer
   
   call exit
   

thread_1:
  xor rcx, rcx
  mov rdi, [list]
  .loop_h:
    xor rax, rax
    mov al, [rdi+rcx]
    inc rcx
    xor rdx, rdx
    mov rbx, 2
    div rbx
    ; xor rax, rax
    ; mov al,dl
    sub byte [rdi+rcx-1], dl

    cmp rcx, [N]
    jne .loop_h
  call exit 
  
thread_2:
    xor rcx, rcx
  mov rdi, [list]
  .loop_h:
    xor rax, rax
    mov al, [rdi+rcx]
    inc rcx
    xor rdx, rdx
    mov rbx, 2
    div rbx
    xor rax, rax
    mov al, dl
    inc rax
    mov rbx, 2
    xor rdx, rdx
    div rbx
    add byte [rdi+rcx-1], dl
    .next:
    cmp rcx, [N]
    jne .loop_h
  call exit 

; rdi array ptr, rax = N
filler:
push rax
push rbx 
push rcx 
push rsi 
  xor rcx, rcx
  .mloop:
    inc rcx
    mov [rdi+rcx-1], rcx
    cmp rcx, rax
    jne .mloop
pop rsi
pop rcx
pop rbx
pop rax
ret

; rdi array ptr, rax = N
printer:
push rax
push rbx 
push rcx 
push rsi 

  xor rcx, rcx
  mov rsi, buffer
  .mloop:
    push rax
    xor rax, rax
    mov al, [rdi+rcx]
    call number_str
    call print_str
    call new_line
    pop rax
    inc rcx
    cmp rcx, rax
    jne .mloop
    

pop rsi
pop rcx
pop rbx
pop rax
ret