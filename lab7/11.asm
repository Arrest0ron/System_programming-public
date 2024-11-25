format elf64
public _start
public is_prime


include 'printlib.asm'
section '.bss' writable
  
  buffer rb 100
	filename_1 rb 255
	filename_2 rb 255
	buf64 rb 64
	newline db 0xA, 0


section '.text' executable

_start:
	mov rsi, filename_1
	call input_keyboard 
	call print_str

	mov rsi, filename_2
	call input_keyboard
	call print_str

	mov rsi, buf64
	call input_keyboard
	call print_str

	call str_number
	cmp rax, 1
	jl .end
	mov rcx, rax

	mov rsi, 1101o
	mov rdx, 777o

	mov rdi, filename_2 
	call open
	mov r13, r12

	mov rdi, filename_1
	call open


	.iter:	
		mov rax, rcx
		
		call is_prime
		cmp rdi, 0
		je .next

		
		mov rsi, buf64
		call number_str
		
		mov rdi, r12
		call write
		mov rsi, newline
		call write
		
		mov rax, rcx
		mov rbx, 10
		xor rdx, rdx
		div rbx
		cmp rdx, 1
		jne .next
	 	
		mov rsi, buf64
		mov rax, rcx
		call number_str
		mov rdi, r13
		call write
		mov rsi, newline
		call write

		.next:
		dec rcx
		jne .iter
		
	mov rdi, r12
	call close
	mov rdi, r13
	call close
	.end:
	call exit


