;5.asm
format ELF64

public _start
section '.bss' writable
msg rb 255
section '.code' executable

include 'printlib.asm'
_start:
	mov rsi, msg
	call input_keyboard
    call str_number
	mov rcx, rax
	mov rax, 1
	xor rbx, rbx
	.loop:
		inc rax
		cmp rax, rcx
		je .end
		call is_divisible_by_11_or_5
		cmp rdi, 0
		jne .loop
		inc rbx
		jmp .loop
	.end:
		mov rax, rbx
		call number_str
		call print_str
		call print_newline


		call exit

;Function tells if number is divisible by 11 or 5
;input rax - number
;output rdi 1 if is, rdi 0 if not
is_divisible_by_11_or_5:
	push rbx
	push rax
	push rdx


	mov rdi, rax
	mov rbx, 5
	xor rdx, rdx
	div rbx
	cmp rdx, 0

	je .true
	mov rax, rdi
	mov rbx, 11
	xor rdx, rdx
	div rbx
	cmp rdx, 0
	je .true

	.false:
		xor rdi, rdi
		jmp .end
	.true:
		mov rdi, 1
		jmp .end

	.end:
		pop rdx
		pop rax
		pop rbx
		ret