format ELF64
public _start

section '.bss' writable
result_string db ?

section '.code.' executable

include 'printlib.asm'
include 'solution1.asm'


_start:
	pop rax
	pop rax
	xor rax, rax
	pop rsi
	mov byte bl, [rsi]
	mov al, bl
	call itoa
	call exit


