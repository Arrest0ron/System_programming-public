

;;ipc1.asm
	
format elf64
public _start
include 'func.asm'

section '.data' writable
  randomfile db "/dev/random", 0
   msg_1 db "Кратно пяти: ",0
   msg_2 db "Третье после максимального: ",0
   msg_3 db "Количество чисел, сумма цифр которых кратна 3: ",0
   msg_4 db "Самая редкая цифра: ", 0
   me1 db "first_class", 0xA, 0
   me2 db "second_class", 0xA, 0
   me3 db "third_class", 0xA, 0
   spac db "    ", 0
   me4 db "fourth_class",0xA,  0
   N dq 6
   BYTE_SIZE dq 0
  num_1 dw 0
  num_2 dw 0
  num_3 dw 0
	num_4 dw 0
  some_number dw 22333
    rarest_one dw 0
  
  rarest_amount dq 0
	
section '.bss' writable
	
	buffer rb 100
  buf2 rb 120
  digits_array rq 10
  digit rb 2
	address rq 1
  number rw 1

  

section '.text' executable
	
_start:
    ; mov rsi, msg_1
    ; call print_str


    ; call new_line
    ; mov rax, [digits_array+3*8]
    ; call number_str
    ; call print_str
    ; call exit
    
    ; call new_linem

    mov rax, [N]
    mov rbx, 2
    mul rbx
    mov [BYTE_SIZE], rax
    mov rsi, buffer

    ;;Первый процесс создает разделяемую память
    mov rdi, 0    ;начальный адрес выберет сама ОС
    mov rsi, [BYTE_SIZE]  ;задаем размер области памяти
    mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
    mov r10, 0x21  ;задаем режим MAP_ANONYMOUS|MAP_SHARED
    mov r8, -1   ;указываем файловый дескриптор null
    mov r9, 0     ;задаем нулевое смещение
    mov rax, 9    ;номер системного вызова mmap
    syscall

    ;;Сохраняем и печатаем адрес памяти
    mov [address], rax
    ; mov rsi, buffer

     mov rdi, randomfile
   mov rax, 2 
   mov rsi, 0o
   syscall 
   mov r8, rax
    call filler
    call printer

    ;;Делаем fork процесса
    
    mov rax, 57
    syscall
    cmp rax, 0
    je divisible_by_five

    mov rax, 57
    syscall
    cmp rax, 0
    je  sum_divisible_by_three 
    mov rax, 57
    syscall
    cmp rax, 0
    je third_after_max
        mov rax, 57
    syscall
    cmp rax, 0
    je rarest_digit
    ; выполняем системный вызов munmap, освобождая память
    mov rdi, [address]
    mov rsi, 1
    mov rax, 11
    syscall
    call exit

; rdi - source string array
add_digits_to_arrays:
  push rax
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  xor rcx, rcx
  .cloop:
  xor rax, rax
    mov BYTE al, [rdi+rcx]
    inc rcx
    cmp al, 0
    je .end
    sub al, 48
    ; call exit

    inc [digits_array+rax*8]
    
    jmp .cloop

  .end:
  pop rdx
  pop rcx
  pop rbx
  pop rax
  ret
 
minimal_array_index:
push rax
 push rbx
 push rcx
 push rdx
   xor rcx,rcx
   xor r8, r8
  mov rsi, buf2
   .mlp: 
  ;  mov rax, [rar]
      ;  call number_/str
    ; call print_str
    mov rax, [digits_array+rcx*8]

    cmp rax, [rarest_amount]
    jg .next
    mov [rarest_one], cx
    mov [rarest_amount], rax
    ; call new_line
    .next:
    inc rcx
    cmp rcx, 10
    
   jne .mlp 
  ;  call new_line
  ;  call new_line
   pop rdx
   pop rcx
   pop rbx 
   pop rax

   ret

rarest_digit:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    mov rsi, buffer
    xor r8, r8
    .mloop:
      push rcx
      xor rbx, rbx
      xor rax, rax
      mov rbx, [address+rcx*2]
      mov ax, bx
      mov rsi, buffer
      call number_str
      mov rdi, rsi
      call add_digits_to_arrays
      
      inc rcx
      cmp rcx, [N]
      jl .mloop
      mov rsi, msg_4
      call print_str
      call minimal_array_index
  
    mov ax, [rarest_one]
    call number_str
    call print_str

    call new_line
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call exit


  

  sum_divisible_by_three:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    mov rsi, buffer
    xor r8, r8
    .mloop:
      push rcx
      xor rbx, rbx
      xor rax, rax
      mov rbx, [address+rcx*2]
      mov ax, bx
      xor rdx, rdx
      mov rbx, 3
      div rbx
      cmp rdx, 0
      jne .end
      inc r9

      .end:
      pop rcx
      inc rcx
      cmp rcx, [N]
      jl .mloop
      mov rsi, msg_3
      call print_str
    mov rax, r9
    call number_str
    call print_str
    call new_line
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call exit

  divisible_by_five:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    mov rsi, buffer
    xor r8, r8
    .mloop:
      push rcx
      xor rbx, rbx
      xor rax, rax
      mov rbx, [address+rcx*2]
      mov ax, bx
      xor rdx, rdx
      mov rbx, 5
      div rbx
      cmp rdx, 0
      jne .end
      inc r8

      .end:
      pop rcx
      inc rcx
      cmp rcx, [N]
      jl .mloop
      mov rsi, msg_1
      call print_str
    mov rax, r8
    call number_str
    call print_str
    call new_line
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call exit
 

; sort:
;     push rax
;     push rbx
;     push rcx
;     push rdx
;     xor rcx, rcx
;     mov rsi, buffer
;     xor r8, r8
;     xor r9, r9
;     xor rax, rax
;     xor rbx, rbx
;     .mloop:
;       push rcx


;         .mloop_in:
;           mov rbx, [address+rcx*2]
;           mov ax, bx
          
;           jne .end_inner
;           inc r9
;           .end_inner:
;           inc r9
;           mov rdx, [N]
;           dec rdx
;           cmp rcx, rdx
;           jl .mloop_in

;       .end:
;       pop rcx
;       inc rcx
;       cmp rcx, [N]
;       jl .mloop
;       mov rsi, msg_1
;       call print_str
;     mov rax, r8
;     call number_str
;     call print_str
;     call new_line
;     pop rdx
;     pop rcx
;     pop rbx
;     pop rax
;     call exit

third_after_max:
  push rax
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rsi, buffer
  ; call new_line
  ; call new_line
  xor r8, r8
  .mloop:
    
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    xor rax, rax
    mov rbx, [address+r8*2]
    mov ax, bx
    ; and rax, rbx
    ; xor rbx, rbx


    push rax
    ; mov rax, r8
    ; mov rsi, buffer
    ; call number_str
    ; call print_str
   pop rax
  ;  mov bx, ax
  ;  xor rax, rax
  ;  mov ax, bx

  ;  call spacing
   push rax
  ;   call number_str
  ;   call print_str
  ;   pop rax
  ;   push rax
  ;   call spacing
  ;   call new_line
  ;   call new_line
  ; call num_status
  pop rax

  ; mov [num_1], ax
  ; jmp .end
  

    
 
    ; push rax
    cmp WORD ax, [num_1]
    jb .ch2
    ; mov rsi, me1
    ; call print_str
    mov bx, [num_1]
    mov cx, [num_2]
    mov dx, [num_3]
    ; pop rax
    mov WORD [num_1], ax
    mov [num_2], bx
    mov [num_3], cx
    mov [num_4], dx
    jmp .end
    .ch2:

    cmp WORD ax, [num_2]
    jb .ch3
    ;     mov rsi, me2
    ; call print_str
    mov bx, [num_2]
    mov cx, [num_3]
    mov [num_2], ax
    mov [num_3], bx
    mov [num_4], cx
    jmp .end
    .ch3:

    cmp WORD  ax, [num_3]
    jb .ch4
    ;     mov rsi, me3
    ; call print_str
    mov bx, [num_3]
    mov [num_3], ax
    mov [num_4], bx
    jmp .end
    .ch4:

    cmp WORD  ax, [num_4]
    jb .end
    ; mov rsi, me1
    ; call print_str
    mov [num_4], ax

    .end:
    
    inc r8
    cmp r8, [N]
    jb .mloop
    mov rsi, msg_2
    call print_str
    xor rax, rax
    mov ax, [num_4]
    
    call number_str
    call print_str
    call new_line
  pop rdx
  pop rcx
  pop rbx
  pop rax
  call exit

filler:
  push rax
  push rbx 
  push rcx 
  push rsi 
    xor rcx, rcx
    .mloop:
    mov rsi, buffer
    push rcx
      mov rax, 0 ;
      mov rdi, r8
      mov rsi, number
      mov rdx, 2
      syscall
      pop rcx
      mov bx, [number]
      mov WORD [address+rcx], bx
      add rcx, 2
      cmp rcx, [BYTE_SIZE]
      jl .mloop

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

      xor rbx, rbx
      xor rax, rax
      mov rbx, [address+rcx*2]
      movzx rax, bx
      call number_str
      call print_str
      call new_line

      inc rcx
      cmp rcx, [N]
      jl .mloop
  pop rsi
  pop rcx
  pop rbx
  pop rax
  ret

spacing:
  push rsi
  push rcx
  mov rsi, spac
  call print_str
  pop rcx
  pop rsi
  ret

num_status:
  push rsi
  push rcx
  push rax
  call new_line
  xor rax, rax
  mov ax, [num_1]
  mov rsi, buffer
  call number_str
  call print_str
  call spacing
  mov ax, [num_2]
  mov rsi, buffer
  call number_str
  call print_str
  call spacing
  mov ax, [num_3]
  mov rsi, buffer
  call number_str
  call print_str
  call spacing
  mov ax, [num_4]
  mov rsi, buffer
  call number_str
  call print_str
  call new_line

  pop rax
  pop rcx
  pop rsi
  ret