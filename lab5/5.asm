format elf64
public _start
public is_prime
public file_len 

include 'printlib.asm'
section '.bss' writable
  
  buffer rb 100
	R dq "7"

	buf64 db 0 dup (64)
	newline db 0xA, 0
	symbol db 0

section '.data' writeable
	filename_1 dq 0 
	filename_2 dq 0
	POS dq 0
	K dq 0
	M dq 0
	MAXPOS dq 0
	MINPOS dq 0

	K_BIG_ERR db "The K number is too big, please, try again.", 0xA, 0
	K_LOW_ERR db "The K number is negative (???), please, try again.", 0xA, 0


section '.text' executable

_start:
	pop rcx
	cmp rcx, 5
	jl .noargs

	pop rsi
	xor rsi, rsi

	pop rsi          ; K
	call str_number
	mov [K], rax

	pop rsi          ; M
	call str_number
	mov [M], rax

	pop rsi          ; F1
	mov [filename_1], rsi
	pop rsi          ; F2
	mov [filename_2], rsi
	
	

	mov rdi, [filename_1]
	call file_len ; getting FILE_LENGTH to r9
	cmp rax, 0
	je .err         ; FILE_EMPTY
	mov r9, rax
	dec r9             ; now it's maximum offset to read byte from zero.
	mov rdi, [filename_1]

	mov rax, 2 
  	mov rsi, 0o 
  	mov rdx, 777o
	syscall ; opening F1
  	
	cmp rax, 0 
  	jl .err

  	mov r8, rax ; r8 = F1 descryptor


	mov rax, [K]
	cmp rax, 0
	jl .K_LOW
	cmp rax, r9
	jg .K_BIG



	.n2:
	mov rax, [K]
	sub rax, [M]
	mov [MINPOS], rax
	cmp rax, 0   ;  MIN POS < 0 ?
	jg .n1
	mov [MINPOS], 0

	.n1:
	mov rax, [K]
	add rax, [M]
	mov [MAXPOS], rax
	cmp rax, r9        ; MAX POS > FILE_LENGTH ?
	jl .iterl
	mov [MAXPOS], r9

	
	;mov rsi, buf64
	;mov rax, [MINPOS]
	;call number_str
	;call print_str
	;call print_newline
	;mov rsi, buf64
	;mov rax, [MAXPOS]
	;call number_str
	;call print_str
	;call print_newline

	.iterl:
	mov rbx, [K]
	mov rax, 0
	

	.iter:
		cmp rbx, [MINPOS]
		jl .end

		cmp rbx, [MAXPOS]
		jg .end
	

		push rax
		push rbx

		;cmp rbx, [K]+[M]
		

  		mov rax, 8
  		mov rdi, r8
  		mov rsi, rbx
  		mov rdx, 3
  		syscall   ; lseek pos

		mov rax, 0
		mov rdi, r8
		mov rdx, 1


		mov rsi, symbol

		syscall ; reading symbol POS
		mov al, [symbol]
		call print_symbol

		pop rbx
		pop rax
		cmp rax, 0
		jl .con
		inc rax
		.con:
		mov rbx, [K]
		add rbx, rax
		neg rax
		
		
		
	jmp .iter
	

	.end:
	call print_newline
	call exit
	.err:
	call err_out
	.noargs:
	call args_out
	.K_LOW:
	mov rsi, K_LOW_ERR
	call print_str
	call exit
	.K_BIG:
	mov rsi, K_BIG_ERR
	call print_str
	call exit 

;rdi , filename adress -> rax = filelen
file_len:
	push rsi
	push rcx
	push rdi
	push r8

	mov rax, 2 
  	mov rsi, 0o 
  	syscall 
  	cmp rax, 0 
  	jl .end
  
  	mov r8, rax
  
  	mov rax, 8
  	mov rdi, r8
  	mov rsi, 0
  	mov rdx, 2
  	syscall
	push rax
    	mov rdi, r8
  	mov rax, 3
  	syscall
	.end:
	pop rax

	pop r8
	pop rdi
	pop rcx
	pop rsi
	ret


