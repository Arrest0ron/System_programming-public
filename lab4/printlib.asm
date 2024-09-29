exit:
	mov rax, 60
	mov rdi, 0
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
	push rdi

	;rsi is  already in place
	call get_len
	mov rax, 1
	mov rdi, 1
	syscall

	pop rdi
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


;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string 
input_keyboard:
  push rax
  push rdi
  push rdx

  mov rax, 0
  mov rdi, 0
  mov rdx, 255
  syscall

  xor rcx, rcx
  .loop:
     mov al, [rsi+rcx]
     inc rcx
     cmp rax, 0x0A
     jne .loop
  dec rcx
  mov byte [rsi+rcx], 0
  
  pop rdx
  pop rdi
  pop rax
  ret


;Function converting the string to the number
;input rsi - place of memory of begin string
;output rax - the number from the string
str_number:
    push rcx
    push rbx

    xor rax,rax
    xor rcx,rcx
.loop:
    xor     rbx, rbx
    mov     bl, byte [rsi+rcx]
    cmp     bl, 48
    jl      .finished
    cmp     bl, 57
    jg      .finished

    sub     bl, 48
    add     rax, rbx
    mov     rbx, 10
    mul     rbx
    inc     rcx
    jmp     .loop

.finished:
    cmp     rcx, 0
    je      .restore
    mov     rbx, 10
    div     rbx

.restore:
    pop rbx
    pop rcx
    ret

;The function converts the number to string
;input rax - number
;output rsi - string beginning adress
number_str:
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rbx, 10
  .loop_1:
    xor rdx, rdx
    div rbx
    add rdx, 48
    push rdx
    inc rcx
    cmp rax, 0
    jne .loop_1
  xor rdx, rdx
  .loop_2:
    pop rax
    mov byte [rsi+rdx], al
    inc rdx
    dec rcx
    cmp rcx, 0
  jne .loop_2
  mov byte [rsi+rdx], 0   
  pop rdx
  pop rcx
  pop rbx
  ret
