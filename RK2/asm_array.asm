
	public create_array
	public free_memory
	public randomize
	public count_even
	public count_odd
	public return_odd
	public get_random
	public reverse


section '.data' 
memory_msg db "Memory was returned to the system: " ,0
memory_msg2 db " bytes from adress: ", 0
reading_error_msg db "There was an error during reading", 0xA, 0
nothing_to_return db "Nothing to return (no odd numbers).", 0xA, 0
f  db "/dev/urandom",0
err_msg db "Something unexpected happened", 0xA, 0 
args_msg db "Not enough arguments", 0xA, 0 
section '.bss' writable

buf8 rq 1
buf_byte rb 1
buf64 rb 64
arr_length rq 1
arr_start rq 1
ARR_ELEMENT_SIZE = 8

section '.text' executable
	


;ret rax - adress
create_array:

	cmp rdi, 0
	jne .usual
	mov rsi, args_msg
	call print_str
	call exit
	.usual:

	mov rsi, rdi
	mov [arr_length], rdi
	;; выполняем анонимное отображение в память
	mov rdi, 0    ;начальный адрес выберет сама ОС
	mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
	mov r10,0x22  ;задаем режим MAP_ANONYMOUS|MAP_PRIVATE
	mov r8, -1   ;указываем файловый дескриптор null
	mov r9, 0     ;задаем нулевое смещение
	mov rax, 9    ;номер системного вызова mmap
	syscall
	mov [arr_start],rax
	xor rsi, rsi
	xor rdi, rdi
	
	ret

; rdi - adress, rsi - length 
free_memory:


	cmp rsi, 0
	jne .usual
	mov rsi, args_msg
	call print_str
	call exit
	.usual:
	mov rax, 11
	syscall 	; выполняем системный вызов munmap, освобождая память
	
	push rsi
	mov rsi, memory_msg
	call print_str
	pop rsi

	mov rax, rsi

	mov rsi, buf64
	call number_str
	call print_str

	mov rsi, memory_msg2
	call print_str
	mov rax, rdi
	mov rsi, buf64
	call number_str
	call print_str
	call print_newline
	ret

randomize:
	cmp rsi, 0
	jne .usual
	mov rsi, args_msg
	call print_str
	call exit
	.usual:
	mov rcx, rsi
	.iter:
		call get_random
		mov [rdi+rcx], al
		dec rcx
		cmp rcx, -1
		jne .iter
	ret

get_random:
	push rcx
	push rdi
	mov rdi, f
	mov rax, 2 
	mov rsi, 0o
	syscall 
	cmp rax, 0 
	jl .l1 
	mov r8, rax

	mov rax, 0 ;
	mov rdi, r8
	mov rsi, buf_byte
	mov rdx, 1
	syscall
	pop rdi
	pop rcx
	mov al, [buf_byte]
	ret
	.l1:
		mov rsi, reading_error_msg
		call print_str
		call exit


count_odd:
	push r9
	push rcx
	push rdx
	push rsi

	cmp rsi, 0
	jg .usual
	mov rsi, args_msg
	call print_str
	call exit
	.usual:
	mov rax, rsi
	mov rbx, ARR_ELEMENT_SIZE
	xor rdx, rdx
	div rbx
	mov rcx, rax

	mov rbx, rax
	push rbx



	xor r9, r9
	dec rcx
	.iter:
		mov rax, [rdi+rcx*ARR_ELEMENT_SIZE]
		mov rbx, 2
		xor rdx, rdx
		div rbx
		add r9, rdx
		dec rcx

		cmp rcx, -1
		jg .iter

	; call print_newline
	pop rbx
	mov rax, r9

	pop rsi
	pop rdx
	pop rcx
	pop r9
	ret

return_odd:
	mov r12, rdi   ; source array ptr = r12
	call count_odd ; rax = odd_amount
	cmp rax, 0
	je .nope
	mov rdi, rax   ; rdi = odd_amount
	mov r13, rdi
	call create_array ; rax = new_array
	xor rcx,rcx
	mov rdi, rax



	; r12[rbx] - odd 
	xor r9, r9
	push rax
	.iter:
		mov rax, [r12+ARR_ELEMENT_SIZE*rcx]
		mov r14, rax
		inc rcx
		mov rbx, 2
		xor rdx, rdx
		div rbx
		cmp rdx, 1
		jne .iter
		mov rdx, r14
		xor rdx, rdx
		mov  [rdi+r9*ARR_ELEMENT_SIZE], r14
		inc r9
		cmp r13, r9
		je .end
		jmp .iter
		.nope:
			mov rsi, nothing_to_return
			call print_str
			mov rax, 0
			ret
	.end:
		pop rax

	ret

count_even:

	call count_odd

	sub rax, rbx
	neg rax
	ret

reverse:
	;rdi ptr, rsi size
	mov rax, rsi
	mov rbx, ARR_ELEMENT_SIZE
	xor rdx, rdx
	div rbx ; rax elements_amount
	mov rcx, -1
	
	.iter:
	dec rax
	inc rcx
	cmp rcx, rax
	jg .end

	mov rdx, [rdi+rax*ARR_ELEMENT_SIZE]
	mov rbx, [rdi+rcx*ARR_ELEMENT_SIZE]

	mov [rdi+rcx*ARR_ELEMENT_SIZE], rdx
	mov [rdi+rax*ARR_ELEMENT_SIZE], rbx

	cmp rcx, rax
	
	jl .iter
	.end:
	ret


; prints 0xA to stdout
print_newline:
	push rax
	mov rax, 0xA
	call print_symbol
	pop rax
	ret


	
; al ->  stdout
print_symbol:
	push rcx
	push rax
	push rsi
   
	push rdx
	push rdi

	dec rsp
	mov [rsp], al
	mov rsi, rsp
	mov rdx, 1
	mov rax, 1
	mov rdi, 1
  	syscall
	inc rsp

	pop rdi
	pop rdx
	pop rsi
	pop rax
	pop rcx
  	ret





