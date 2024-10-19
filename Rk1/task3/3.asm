;;;The program demonstrates makimg of directory and getting rigth of the file in architecture x86-64

format elf64
public _start
public repetition
section '.bss' writable

msg rb 255
include "printlib.asm"
section '.text' executable


_start:

;системный вызов read
	mov rsi, msg
	call input_keyboard



;системный вызов umask
   mov rax, 95
   mov rdi, 000000001b
   syscall

	mov rax, 4
	call repetition

;системный вызов mkdir
   mov rax, 83
   mov rdi, msg
   mov rsi, 111111111b
   syscall

;системный вызов exit
   mov rax, 60
   mov rdi, 0
   syscall


;input rax, rsi
;output rdi

repetition:
	mov r8, rsi
	call get_len
	mov r9, rdx

	.iter:	
		.iter2:

			dec rdx
			cmp rdx, 0
			jne .iter2
		
		dec rax
		cmp rax, 0
		jne .iter
	ret





