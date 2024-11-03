;;;The program demonstrates makimg of directory and getting rigth of the file in architecture x86-64

format elf64
public _start
section '.bss' writable

msg rb 255
buf64 rb 64
string1 rb 255
string2 rb 64
string3 rb 255

section '.data' writable
N dq 0
include "printlib.asm"
section '.text' executable


_start:
	pop rsi
	pop rsi
	xor rsi, rsi



	pop rsi
	mov rdi, string1
	call strcpy
	mov rbx, rsi

	mov  rsi, string2
	pop rsi
	call str_number
	mov [N], rax

	mov rsi, rbx


	xor rbx, rbx
	.iter:
		push rbx

		push rdi
	;системный вызов umask
		mov rax, 95
		mov rdi, 000000001b
		syscall
		pop rdi

		push rsi
		push rdi

		;системный вызов mkdir
		mov rax, 83
		mov rsi, 111111111b
		syscall
		pop rdi
		pop rsi


		mov rax, rsi
		mov rsi, rdi
		mov rdi, rax

		
		call addslash
		call concatate ; rsi = .../...  rdi = ...
		
		mov rax, rsi
		mov rsi, rdi
		mov rdi, rax

		pop rbx
		inc rbx
		cmp rbx, [N]
		jl .iter


; ;системный вызов exit
   mov rax, 60
   mov rdi, 0
   syscall


; rsi, rdi -> rsi+rdi ->  rsi
concatate:
	push rax
	push rcx

	push rsi
	mov rsi, rdi
	call get_len
	mov rax, rdx
	mov r9, rax
	pop rsi
	call get_len
	mov rbx, rdx
	add r9, rbx
	xor rcx, rcx

	.iter:

		mov byte dl, [rdi+rcx]
		mov byte [rsi+rbx], dl
		inc rcx
		inc rbx
		cmp rcx, rax
		jne .iter
	
	
	mov byte [rsi+r9], 0
	pop rcx
	pop rax
	ret

; rsi, rdi -> rdi = rsi
strcpy:
	push rdi
	push rsi
	push rax
	push rcx
	push rbx


	call get_len


	.iter:

		mov byte bl, [rsi+rcx]
		mov byte [rdi+rcx], bl
		inc rcx
		cmp rcx, rdx
		jne .iter
	
	
	mov byte [rdi+rdx], 0

	pop rbx
	pop rcx
	pop rax
	pop rsi
	pop rdi
	ret

; rsi -> rsi/
addslash:
	push rax
	push rcx
	push rbx

	call get_len


	mov byte [rsi+rdx], '/'
	mov byte [rsi+rdx+1], 0

	pop rbx
	pop rcx
	pop rax
	ret
	

	
	




