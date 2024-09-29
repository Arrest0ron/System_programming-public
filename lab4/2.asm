format ELF64

public _start
section '.data' writable
result dq 0
section '.code' executable

include 'printlib.asm'
include 'solution1.asm'

_start:
	add rsp, 16
	xor rax, rax

	pop rsi
	call stoi
	add [result], rax



	pop rsi
	call stoi
	sub [result], rax
	mov rax, [result]
	call itoa
	call exit
