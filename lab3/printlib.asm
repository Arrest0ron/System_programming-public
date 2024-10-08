;process exit
exit:
	mov rax, 60
	mov rsi, 0
	syscall

;rsi (string memory adress start) -> rdx (length of 0-terminated string)
get_len:
	xor rdx, rdx
	.iter:
		inc rdx
		cmp byte [rsi+rdx], 0		
		jne .iter
	ret

;prints 0-terminated string from [rsi] to stdout
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

; prints 0xA to stdout
print_newline:
	push rax
	mov rax, 0xA
	call print_symbol
	pop rax
	ret


;rsi (string memory adress start) -> rax (number)
stoi:
	push rbx
	push rcx
	push rdx
	push r8

	mov r8, 1
	xor rax, rax
	xor rcx, rcx
	cmp byte [rsi], 45
	jne .loop
	mov r8, -1
	inc rcx
	.loop:
		xor rdx, rdx
		mov byte dl, [rsi+rcx]
		cmp dl, 48
		jl .sign
		cmp dl, 57
		jg .sign
		
		.p2:
		sub dl, 48
		add rax, rdx
		cmp byte [rsi+rcx+1], 0
		je .sign
		mov rbx, 10
		mul rbx
		inc rcx
	jmp .loop

	.sign:
		cmp r8, 0
		jg .end
		neg rax
	.end:	 
	pop r8
	pop rdx
	pop rcx
	pop rbx
	ret


	
; al ->  stdout
print_symbol:
	push rcx
	push rax
	push rsi
	push rdx
	dec rsp
	mov [rsp], al
	mov rsi, rsp
	mov rdx, 1
	mov rax, 1

  	syscall
	inc rsp
	pop rdx
	pop rsi
	pop rax
	pop rcx
  	ret

; num rax -> sum of its digits in the rbx
digits_sum:	
	push rax
	push rcx
	push rdx
	mov rcx, 10
	.iter:
		xor rdx, rdx
		div rcx
		add rbx, rdx
		cmp rax, 0
		jne .iter

	pop rdx
	pop rcx
	pop rax
	ret



















