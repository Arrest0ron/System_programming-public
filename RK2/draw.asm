;;draw.asm

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
	extrn clear
	extrn addch
	extrn refresh
	extrn endwin
	extrn exit
	extrn color_pair
	extrn insch
	extrn cbreak
	extrn timeout
	extrn mydelay
	extrn sin
	extrn get_cords

	section '.bss' writable

	xmax dq 1
	counstX dq 1
	ymax dq 1
	counstY dq 1
	palette dq 1
	count dq 1

	section '.data' writable
	delay dq 52500
	rand_x dq 0
	rand_y dq 5
	xmin dq 2
	ymin  dq 2
	current_move dq 0

	digit db '0123456789'

	section '.text' executable

_start:

	;; Инициализация
	call initscr

	;; Размеры экрана
	xor rdi, rdi
	mov rdi, [stdscr]
	call getmaxx
	dec rax
	mov [xmax], rax
	mov [counstX], rax
	call getmaxy
	dec rax
	mov [ymax], rax
	mov [counstY], rax

	call start_color

	;; Синий цвет
	mov rdx, 0x004
	mov rsi, 0x004
	mov rdi, 0x1
	call init_pair

	;; фиолетовый цвет
	mov rdx, 0x005
	mov rsi,0x005
	mov rdi, 0x2
	call init_pair

	call refresh
	call noecho
	call cbreak

	;; Начальная инициализация палитры
	mov rax, ' '
	or rax, 0x1
	mov [palette], rax
	mov [count], 0
	mov [current_move],0


	;; Главный цикл программы
mloop:





	.M1:
		mov rcx, [xmax]
		cmp [rand_x], rcx
		jne .M1A
		mov [rand_x], 0
		mov [rand_y], 5
		call change_color
		jmp .decision
		.M1A:
		inc [rand_x]
		mov rdi, [rand_x]
		call get_cords

		add [rand_y], rax
		jmp .decision


	.decision:
	;; Перемещаем курсор
	mov rdi, [rand_y]
	mov rsi, [rand_x]

	call move

	;; Печатаем
	mov rax, [palette]
	and rax, 0x100
	cmp rax, 0x100
	jne @f
	mov rax, ' '
	or rax, 0x100
	mov [palette],rax
	jmp yy
	@@:
	mov rax, ' '
	or rax, 0x200
	mov [palette],rax
	yy:
	mov  rdi,[palette]
	call addch
	;; 	call insch

	;; Задержка
	mov rdi,[delay]
	call mydelay

	;; Обновляем экран 
	call refresh


    ;;Задаем таймаут для getch
	mov rdi, 2
	call timeout
	call getch

    ;;Анализируем нажатую клавишу
	cmp rax, 'c'
	je next

	cmp rax, 'm'
	jne mloop
	mov rax, [delay]
	xor rdx,rdx
	mov rcx, 2
	div rcx
	cmp rax, 0
	jne .dela
	mov rax, 52250
	.dela:
	mov [delay], rax

	jmp mloop
next:
	call endwin
	call exit

change_color:
	mov r8,[palette]
	and r8, 0x100
	cmp r8, 0x100
	je .pp
	mov rax, ' '
	or rax, 0x100
	mov [palette], rax
	xor r8, r8
	mov [count],r8
	ret
	.pp:
	mov rax, ' '
	or rax, 0x00
	mov [palette], rax
	xor r8, r8
	mov [count], r8
	ret
	.p:
	 ret