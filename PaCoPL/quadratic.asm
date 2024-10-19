format ELF64 executable 3
entry start

segment readable executable

start:
    ; Загрузка коэффициентов a, b, c
    fld dword [a]
    fld dword [b]
    fld dword [c]

    ; Вычисление дискриминанта: b^2 - 4ac
    fld st1
    fmul st0, st0
    fld st2
    fmul st0, st0
    fld st2
    fmul st0, st0
    fsubp st1, st0

    ; Проверка, является ли дискриминант отрицательным
    ftst
    fstsw ax
    sahf
    jb no_real_roots

    ; Вычисление квадратного корня из дискриминанта
    fsqrt

    ; Вычисление двух корней
    ; x1 = (-b + sqrt(discriminant)) / (2a)
    ; x2 = (-b - sqrt(discriminant)) / (2a)

    ; Вычисление -b
    fld st1
    fchs

    ; Вычисление -b + sqrt(discriminant)
    fadd st0, st1

    ; Деление на 2a
    fld dword [two]
    fld dword [a]
    fmul st0, st1
    fdivp st1, st0

    ; Сохранение первого корня
    fstp dword [x1]

    ; Вычисление -b - sqrt(discriminant)
    fld st1
    fchs
    fsub st0, st1

    ; Деление на 2a
    fld dword [two]
    fld dword [a]
    fmul st0, st1
    fdivp st1, st0

    ; Сохранение второго корня
    fstp dword [x2]

    ; Вывод корней
    mov rdi, msg
    call printf

    movss xmm0, dword [x1]
    cvtss2sd xmm0, xmm0
    mov rdi, format_float
    mov rax, 1
    call printf

    mov rdi, newline
    call printf

    movss xmm0, dword [x2]
    cvtss2sd xmm0, xmm0
    mov rdi, format_float
    mov rax, 1
    call printf

    mov rdi, newline
    call printf

    jmp exit

no_real_roots:
    ; Вывод сообщения о том, что нет действительных корней
    mov rdi, msg_no_real_roots
    call printf

exit:
    ; Завершение программы
    mov rax, 60
    xor rdi, rdi
    syscall

segment readable writable

a   dd  1.0
b   dd  2.0
c   dd  1.0
two dd  2.0
four dd 4.0
msg db 'The roots of the quadratic equation are: ', 0
msg_no_real_roots db 'No real roots exist.', 0
newline db 10, 0
format_float db '%f', 0
x1  dd  0.0
x2  dd  0.0

segment readable writable

extern printf