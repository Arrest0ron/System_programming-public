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






uninit:
    xor rcx, rcx

    mov rax, [number]
    call digits_sum
    mov [number], rbx

    .iter1:
      xor rdx, rdx
      mov rcx, 10
      mov rax, [number]
        div rcx 
	mov [number], rax
      mov al, dl
      add al, '0'
      inc [len]
      push rax
      cmp [number], 0
      jne .iter1

    .iter2:
      pop rax
      call print_symbol
      dec [len]
      jne .iter2

    mov al, 0xA
    call print_symbol

    jmp exit
















