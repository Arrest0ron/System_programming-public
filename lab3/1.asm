format ELF64
public _start

section '.data' writable
string db "my name is Gustavo Fring. But you can call me Gus.", 0xA, 0

section '.code.' executable

include 'printlib.asm'
_start:
	add rsp, 16
	pop rsi
	call stoi
	.loop:	
		cmp rax, 0
		je .exit
		dec rax
		mov rsi, string
		call print_str
		jmp .loop
	.exit:
		call exit



