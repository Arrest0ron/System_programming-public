format ELF64

public _start
public exit
public print_symb

section '.bss' writeable
  pointer db 15 dup ('%'), 0xA

section '.text' executable
  _start:
    mov rcx, 29
    .iter1:
      push rcx
      call print_symb
      pop rcx

      cmp rcx, 0
      loop .iter1
    jmp exit

print_symb:
  mov rax, 4
  mov rbx, 1
  mov rcx, pointer
  mov rdx, 16
  int 0x80
  ret

exit:
  mov eax, 1
  xor ebx, ebx
  int 0x80