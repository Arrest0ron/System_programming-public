format ELF64
public _start
number dq 4894269367
pointer db ?
len db 0
_start:
xor rcx, rcx
mov rax, [number]
call sum
mov [number], rbx
.iter1:
  xor rdx, rdx
  mov rcx, 10
  mov rax, [number]
  div rcx
  mov [number], rax
  mov al, dl
  add al, '0'
  inc [len]
  push rax
  cmp [number], 0
  jne .iter1
.iter2:
  pop rax
  call print_symb
  dec [len]
  jne .iter2
mov al, 0xA
call print_symb
mov eax, 1
xor ebx, ebx
int 0x80
print_symb:
  mov [pointer], al
  mov rcx, pointer
  mov rdx, 1
  mov rax, 4
  mov rbx, 1
  int 0x80
  ret
sum:
  mov rcx, 10
  .iter:
  xor rdx,rdx
  div rcx
  add rbx, rdx
  cmp rax, 0
  jne .iter
  ret
