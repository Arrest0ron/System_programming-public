format ELF64

public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep
extrn printw

section '.bss' writable
    xmax dq 1
  ymax dq 1
    xmid dq 1
    ymid dq 1
  palette dq 1
    delay dq ?

section '.text' executable

_start:
    call initscr
  mov rdi, [stdscr]
    ;максимальные значения координат окна
  call getmaxx
    dec rax
  mov [xmax], rax
    ;середина монитора
    xor rcx, rcx
    mov rcx,2     
    xor rdx, rdx
    div rcx
    mov [xmid],rax

  call getmaxy
    dec rax
  mov [ymax], rax
    ;середина монитора
    xor rcx, rcx
    mov rcx,2     
     xor rdx, rdx
    div rcx
    mov [ymid],rax

    call start_color
    ; COLOR_BLUE
    mov rdi, 1
    mov rsi, 4
    mov rdx, 4
    call init_pair

    ; COLOR_MAGENTA
    mov rdi, 2
    mov rsi, 5
    mov rdx, 5
    call init_pair

    call refresh
  call noecho
  call raw

    mov rax, ' '
    or rax, 0x200
    mov [palette], rax

    .begin:
    mov rax, [palette]
    and rax, 0x100
    cmp rax, 0
    jne .mag

    mov rax, [palette]
    and rax, 0xff
    or rax, 0x100
    jmp @f

    .mag:
    mov rax, [palette]
    and rax, 0xff
    or rax, 0x200

    @@:
    mov [palette], rax

    mov r8, [xmax]
    xor r9, r9
    jmp .loop_to_left

    .to_left:
    inc r9
    cmp r9, [ymax]
    jg .begin
    mov r8, [xmax]

    .loop_to_left:
        mov rdi, [delay]
        call usleep
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh

        mov rdi, 1
        call timeout
        call getch
        cmp rax, 'z'
        jne @f
        jmp .exit

        @@:
        cmp rax, 'h'
        jne @f
        cmp [delay], 2000
        je .fast1
        mov [delay], 2000
        jmp @f
        .fast1:
        mov [delay], 100

        @@:
        pop r9
        pop r8
        dec r8
        cmp r8, 0
        jl .to_right
        jmp .loop_to_left

    .to_right:
    inc r9
    cmp r9, [ymax]
    jg .begin
    mov r8, 0

    .loop_to_right:
        mov rdi, [delay]
        call usleep
        mov rdi, r9
        mov rsi, r8
        push r8
        push r9
        call move
        mov rdi, [palette]
        call addch
        call refresh

        mov rdi, 1
        call timeout
        call getch
        cmp rax, 'x'
        jne @f
        jmp .exit

        @@:
        cmp rax, 'r'
        jne @f
        cmp [delay], 2000
        je .fast2
        mov [delay], 2000
        jmp @f
        .fast2:
        mov [delay], 100
        
        @@:
        pop r9
        pop r8
        inc r8
        cmp r8, [xmax]
        jg .to_left
        jmp .loop_to_right

    .exit:
    call endwin
    call exit
