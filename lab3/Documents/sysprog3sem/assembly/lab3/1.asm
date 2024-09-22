format ELF64
public _start

section '.code' executable

;process exit
exit:
	mov rax, 60
	mov rsi, 0
	syscall

;saves len of 0-terminated string from [rsi] into rdx
get_len:
	xor rdx, rdx
	.iter:
		inc rdx
		cmp byte [rsi+rdx], 0		
		jne .iter
	ret

;prints 0-terminated string from [rsi] to standart output
print_str:
	push rax
	push rcx
	push rdx
	mov rax, 1
	;rsi is  already in place
	call get_len
	syscall
	pop rdx
	pop rcx
	pop rax
	ret
	






