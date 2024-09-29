format ELF64
public _start

section '.data' writable
message db 49 dup (0)
	
section '.code' executable
	
include 'printlib.asm'
include 'solution1.asm'

_start:
mov edi, message
mov eax, 80000002h
cpuid
mov [edi], eax
add edi, 4
mov [edi], ebx
add edi, 4
mov [edi], ecx
add edi, 4
mov [edi], edx
add edi, 4
mov eax, 80000003h
cpuid
mov [edi], eax
add edi, 4
mov [edi], ebx
add edi, 4
mov [edi], ecx
add edi, 4
mov [edi], edx
add edi, 4
mov eax, 80000004h
cpuid
mov [edi], eax
add edi, 4
mov [edi], ebx
add edi, 4
mov [edi], ecx
add edi, 4
mov [edi], edx
mov rsi, message
call print_str
call print_newline
call exit
