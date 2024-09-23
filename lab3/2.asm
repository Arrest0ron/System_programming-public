format ELF64

public _start
section '.data' writable
result dq 0
section '.code' executable

include 'printlib.asm'
include 'solution1.asm'


_start:
	pop rax
	pop rax
	xor rax, rax

	pop rsi
	call stoi
	imul rax, 2
	add [result], rax
	pop rsi
	call stoi
	add [result], rax
	pop rsi
	call stoi
	imul rax, 2
	add [result], rax
	mov rax, [result]
	call itoa
	call exit
