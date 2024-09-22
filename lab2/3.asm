format ELF64

public _start
public exit
public print_symb

section '.data' writeable
  string db '%'
  pointer db ?
  len dq 0


section '.text' executable
  _start:
    xor rcx, rcx

    .loop1:
      inc rcx
      push rcx

      xor rdx, rdx
      .loop2:

        push rdx
        mov al, '%'
        call print_symb
        pop rdx
        inc rdx

        pop rcx
        cmp rdx, rcx
        push rcx

        jne .loop2

      mov al, 0xA
      call print_symb

      pop rcx
      add [len], rcx
      cmp [len], 435
      jne .loop1

    jmp exit

print_symb:
  mov [pointer], al
  mov rcx, pointer
  mov rdx, 1
  mov rax, 4
  mov rbx, 1
  int 0x80
  ret

exit:
  mov eax, 1
  xor ebx, ebx
  int 0x80