
section '.data' writable

f  db "/dev/urandom",0

section '.bss' writable

  number rq 1
  place rb 100

section '.text' executable

random:
   mov rdi, f
   mov rax, 2 
   mov rsi, 0o
   syscall 
   cmp rax, 0 
   jl .l1 
   mov r8, rax

   mov rax, 0 ;
   mov rdi, r8
   mov rsi, number
   mov rdx, 1
   syscall
   
   mov rax, [number]
   ret
