format ELF64

public _start
public exit
public print_symb

section '.bss' writable
  array db 0,0xA, "aKKMkHgJpgHXkotOhCawWoKDqspy"
  place db ?

section '.text' executable
  _start:
    mov rcx, 29
    .iter:
       mov al, [array+rcx]
       push rcx
       call print_symb
       pop rcx
       dec rcx
       cmp rcx, 0
       jne .iter
    call exit

print_symb:
  push rax
  mov eax, 4
  mov ebx, 1
  pop rdx
  mov [place], dl
  mov ecx, place
  mov edx, 1
  int 0x80
  ret

exit:
  mov eax, 1
  mov ebx, 0
  int 0x80