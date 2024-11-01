format elf64
	public create_array
	public free_memory
	public push_end

section '.data' 
memory_msg db "Memory was returned to the system: " ,0
memory_msg2 db " bytes from: ", 0
section '.bss' writable

buf64 rb 64
arr_length rq 1
arr_start rq 1

section '.text' executable
	
include "func.asm"

;ret rax - adress
create_array:
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



	cmp rdi, 0
	jne .usual
	mov rdi, [arr_start]

	mov rsi, [arr_length]

	;; выполняем системный вызов munmap, освобождая память
	.usual:
	mov rax, 11
	syscall
	
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

push_end:
	mov rdi, 8
	cmp rdi, 0
	
	jne .usual
	mov rdi, [arr_start]
	mov rdx, rsi
	mov rsi, [arr_length]
	.usual:
	
	; push rsi
	; mov rax, [arr_start]
	; mov rsi, buf64
	; call number_str
	; call print_str
	; call print_newline
	; pop rsi
	

	; mov rbx, [arr_start]
	; ; add rbx, [arr_length]
	; mov qword [rbx+8], 9
	; mov qword [rbx], 8
	; mov qword [rbx+16], 7
	; mov qword [rbx+32], 6
	; mov qword [arr_start+8], 9
	; mov qword [arr_start], 8
	; mov qword [arr_start+16], 7
	; mov qword [arr_start+32], 6
	; push rsi
	; mov rax, [rbx]
	; mov rsi, buf64
	; call number_str
	; call print_str
	; call print_newline
	; call print_newline
	; pop rsi

	; add rsi, 8
	ret

	