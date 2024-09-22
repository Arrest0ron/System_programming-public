format ELF64
public _start

section '.bss' writeable
    number dq 1111111111      ; Заданное число
    sum dq 0                    ; сумма цифр
    string db ?
    cycle dq 0

section '.text' executable
_start:
    mov rax, [number]
    mov rcx, 10
    xor rbx, rbx

    mov rsi, 1

    ; суммирование цифр числа
    .iter:
      xor rdx, rdx
      div rcx
      add [sum], rdx
      cmp rax,0
      mov rsi, 2
    jne .iter

    

    mov rsi, 3
    ;перевод суммы в строку
    xor rax,rax
    mov rax, [sum]

    mov rcx, 10
    xor rbx, rbx

    mov rsi, 4

    .iter1:
      mov rsi, 5
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax,0
      mov rsi, 6
    jne .iter1

    ; вывод суммы
    mov rsi, 7
    mov [cycle], rbx
    .iter2:
      mov rsi, 8
      pop rax
      call print_symb
      dec [cycle]
      cmp [cycle], 0
    jne .iter2
    mov rsi, 9

 call exit



print_symb:
  
  mov [string], al
  mov rax, 4
  mov rbx, 1
  mov rcx, string
  mov rdx, 1
  int 0x80
  ret

exit:
  mov eax, 1
  mov ebx, 0
  int 0x80
