format ELF64
public _start

section '.data' writable
string db "my name is Gustavo Fring. But you can call me Gus.", 0
number dq "12", 0 
len db 0
section '.code.' executable

include 'printlib.asm'
_start:

	mov rsi, number
	call stoi

	mov rcx, rax
	.iter:
		mov rsi, number
		call print_str
		call print_newline
	loop .iter

	call exit



