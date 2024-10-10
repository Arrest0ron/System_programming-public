format elf64
public _start
public is_prime
public file_len 

include 'printlib.asm'
section '.bss' writable
  
  buffer rb 100
	filename_1 rb 255
	filename_2 rb 255
	buf64 db 0 dup (64)
	newline db 0xA, 0
	symbol db 0


section '.text' executable

_start:
	m = 1
	mov rsi, buf64
	call input_keyboard
	mov rdi, buf64
	call file_len ; rax = filelen

	mov rdi, buf64
	mov rsi, rdi
	call print_str
	mov rax, 2 
  	mov rsi, 0o 
  	mov rdx, 777o
	syscall 
  	
	cmp rax, 0 
  	jl .err

  	mov r8, rax
  	mov rax, 8
  	mov rdi, r8
  	mov rsi, 1+m
  	mov rdx, 3
  	syscall

	mov rax, 0
	mov rdi, r8
	mov rdx, 1
	mov rsi, symbol
	syscall
	mov al, [symbol]
	call print_symbol
	

	.end:
	call exit
	.err:
	call err_out

;rdi , filename adress -> rax = filelen
file_len:
	push rsi
	push rcx
	push rdi
	push r8

	mov rax, 2 
  	mov rsi, 0o 
  	syscall 
  	cmp rax, 0 
  	jl .end
  
  	mov r8, rax
  
  	mov rax, 8
  	mov rdi, r8
  	mov rsi, 0
  	mov rdx, 2
  	syscall
	push rax
    	mov rdi, r8
  	mov rax, 3
  	syscall
	.end:
	pop rax

	pop r8
	pop rdi
	pop rcx
	pop rsi
	ret
