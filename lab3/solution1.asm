
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
;results can be rewritten by push, use carefully
itoa:
	push rax
	push rbx
	push rcx
	push rdx
	
	sub rsp, 32
	mov rcx, 10
	xor rbx, rbx
	
	cmp rax, 0
	jg .loop
	neg rax
	push rax
	mov al, '-'
	call print_symbol
	pop rax
	inc rbx

	
	.loop:
		xor rdx, rdx
		div rcx
		add dl, '0'
		mov byte [rsp+rbx], dl
		inc rbx
		cmp rax, 0
	        jne .loop

	.end:

	mov byte [rsp+rbx], 0
	mov rsi, rsp
	call reverse_print
	add rsp, 32

	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret
