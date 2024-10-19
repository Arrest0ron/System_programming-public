;5.asm
format ELF64

public _start
section '.bss' writable
msg rb 255

N dq 0
section '.code' executable

include 'printlib.asm'
_start:
	pop rax
	pop rax
	xor rax, rax

	pop rsi
	call str_number
	mov [N], rax
	xor rcx, rcx
	xor r9, r9

	.iter:
		mov rax, rcx
		mov rsi, msg
		push rax
		push rcx
		push rdi
		push rsi
		call number_number
		add r9, rax
		call number_str
		call print_str
		call print_newline
		pop rsi
		pop rdi
		pop rcx
		pop rax
	
		cmp rcx, [N]
		je .end
		inc rcx

	jmp .iter
	

	.end:
	call print_newline
	mov rax, r9

	call number_str
	call print_str
	call print_newline

	call exit


;rsi (string memory adress start) -> stdout (in reverse)
reverse_print:
	push rax
	push rdx
	call get_len
    	.iter:
		mov al, [rsi+rdx]
		cmp al, '0'
		je .next
		call print_symbol
		.next:
		dec rdx
		cmp rdx, -1
		jne .iter
	call print_newline
	pop rdx
	pop rax
	ret
