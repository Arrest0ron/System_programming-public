

;;ipc1.asm
	
format elf64
public _start
include 'func.asm'

section '.data' writable
  randomfile db "/dev/random", 0
   msg_1 db "First process",0
   msg_2 db "Second process",0
   msg_3 db "Third process",0
   N dq 629
   BYTE_SIZE dq 0
  num_1 dw 0
  num_2 dw 0
  num_3 dw 0
	num_4 dw 0
	
section '.bss' writable
	
	buffer rb 100
	address rq 1
  number rw 1

section '.text' executable
	
_start:
    mov rsi, msg_1
    call print_str
    call new_line

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

    ;;Делаем fork процесса
    
    mov rax, 57
    syscall
    cmp rax, 0
    je fork_process1

    mov rax, 57
    syscall
    cmp rax, 0
    je fork_process2

    mov rax, 57
    syscall
    cmp rax, 0
    je third
    
    ;; выполняем системный вызов munmap, освобождая память
    mov rdi, [address]
    mov rsi, 1
    mov rax, 11
    syscall
    call exit
  

  fork_process1:
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
      inc r8

      .end:
      pop rcx
      inc rcx
      cmp rcx, [N]
      jl .mloop
    mov rax, r8
    call number_str
    call print_str
    call new_line
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call exit

  fork_process2:
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
    mov rax, r8
    call number_str
    call print_str
    call new_line
    pop rdx
    pop rcx
    pop rbx
    pop rax
    call exit

third:
  push rax
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rsi, buffer
  .mloop:
    push rcx
    xor rbx, rbx
    xor rax, rax
    mov rbx, [address+rcx*2]
    mov ax, bx
    cmp ax, [num_1]
    jl .ch2

    mov bx, [num_1]
    mov cx, [num_2]
    mov dx, [num_3]
    mov [num_1], ax
    mov [num_2], bx
    mov [num_3], cx
    mov [num_4], dx
    jmp .end
    .ch2:

    cmp ax, [num_2]
    jl .ch3
    mov bx, [num_2]
    mov cx, [num_3]
    mov [num_2], ax
    mov [num_3], bx
    mov [num_4], cx
    jmp .end
    .ch3:

    cmp ax, [num_3]
    jl .ch4
    mov bx, [num_3]
    mov [num_3], ax
    mov [num_4], bx
    jmp .end
    .ch4:

    cmp ax, [num_4]
    jl .end
    mov [num_4], ax

    .end:
    pop rcx
    inc rcx
    cmp rcx, [N]
    jl .mloop
    xor rax, rax
    mov ax, [num_4]
    call new_line
    call number_str
    call print_str
    call new_line
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