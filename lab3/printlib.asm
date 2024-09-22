;process exit
newline db 0xA,0
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

print_newline:
	push rsi
	mov rsi, newline
	call print_str
	pop rsi
	ret

;rsi (string memory adress start) -> rax (number)	
stoi:
	push rbx
	push rcx
	push rdx

	xor rax, rax

	xor rcx, rcx
	.loop:
		xor rdx, rdx
		mov byte dl, [rsi+rcx]
		cmp dl, 48
		jl .end
		cmp dl, 57
		jg .end
		sub dl, 48
		add rax, rdx
		cmp byte [rsi+rcx+1], 0
		je .end
		mov rbx, 10
		mul rbx
		inc rcx
	jmp .loop
	.end:	

	pop rdx
	pop rcx
	pop rbx
	ret

print_args:
	pop rbx
	pop rcx ;amount of arguments
	xor rax, rax
	.printloop:
		cmp rcx, rax
		je .end
		mov rsi, [rsp+8*rax]
		call print_str
		call print_newline
		inc rax
	.end:
		push rbx
		ret























