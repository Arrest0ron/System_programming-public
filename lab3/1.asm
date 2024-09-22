format ELF64
public _start

section '.bss' writable
result_string db ?

section '.code.' executable

include 'printlib.asm'

;rsi (string memory adress start) -> stdout (in reverse)
reverse_print:
	push rax
	push rdx
	call get_len
    	.iter:
		mov al, [rsi+rdx]
		call print_symbol
		dec rdx
		cmp rdx, -1
		jne .iter
	call print_newline
	pop rdx
	pop rax
	ret

;rax int -> rsi string
itoa:
	push rax
	push rbx
	push rcx
	push rdx
	mov rcx, 10
	xor rbx, rbx
	.loop:
		xor rdx, rdx
		div rcx
		add dl, '0'
		mov byte [result_string+rbx], dl
		inc rbx
		cmp rax, 0
	        jne .loop
	mov [result_string+rbx], 0
	mov rsi, result_string
	call reverse_print
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret
	

_start:
	pop rax
	pop rax
	xor rax, rax
	pop rsi
	mov byte bl, [rsi]
	mov al, bl
	call itoa
	call exit


