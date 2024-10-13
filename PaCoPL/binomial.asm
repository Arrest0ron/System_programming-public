format elf64 
public _start

include 'printlib.asm'
section '.bss' writable
buf64 rb 64
section '.data' writable
A dq ?
B dq ?
C dq ?
DIS dq ?
res dq ?
section '.text' executable 

_start:
	mov rsi, buf64


	call input_keyboard
	call str_number
	mov [A], rax

	call input_keyboard
	call str_number
	mov [B], rax

	call input_keyboard
	call str_number
	mov [C], rax

	mov rax, 9
	sqrt rax
	call str_number
	call print_str

	
	call exit
