format ELF64

include 'func.asm'
extrn printf
extrn exp
extrn pow
;extrn exit
;fasm pi_series.asm && ld pi_series.o -lc -lm -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o pi_series.out

section '.data' writable
    fmt1 db "Первое представление: %d итераций, точность: %.10f", 10, 0
    fmt2 db "Второе представление: %d итераций, точность: %.10f", 10, 0
    true_output db "True number: %.15f for x: %.2f", 0xA, 0
    calc_output db "Calc number: %.15f for x: %.2f", 0xA, 0
    tolerance dq 0.00000001           ; Заданная точность
    e_real dq 2.71828182846

    zero dq 0.0
    one dq 1.0
    two dq 2.0
    three dq 3.0

    numbers dq 0.0, 0.25, 0.5,0.75,  1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5
    counter dq 0
    evaluation_n dq 2999
    
    x dq 0.0
    n dq 1
    cur_n dq 0
    
    
    ; two dq 2.0

section '.bss' writable
    
    result rq 10
    ultra_res rq 10
section '.text' executable
public _start
_start:
    ; mov rax, [one]
    ; mov [x], rax
    ; call correct ;xmm0 correct
    ; movq xmm1, [x]
    ; mov rax, 2
    ; mov rdi, true_output
    ; call printf
    ; mov rsi, 0

                                .mlp2:
    ; mov [counter], 5
    ; push rcx
            mov rbx, [counter]
            mov rax, [numbers+8*rbx]
            mov [x], rax
            call correct ;xmm0 correct
            movq xmm1, [x]
            mov rax, 2
            mov rdi, true_output
            ; push rdx
            call printf
            ; pop rdx

            mov rbx, [counter]
            mov rax, [numbers+8*rbx]
            mov [x], rax
            mov rax, [evaluation_n]
            mov [n], rax
            call sum_for_n
            movq xmm0, [ultra_res]
            mov rbx, [counter]
            movq xmm1, [numbers+8*rbx]
            mov rax, 2 
            mov rdi, calc_output
            call printf
        ; pop rcx
                                        inc [counter]
                                        cmp [counter], 10
                                        jl .mlp2
            
    ;  mov rax, [two]
    ; mov [x], rax
    ; mov [n], 5
    ; call pow_2n_div_fact
    ; fstp [ultra_res]
    ; movq xmm0, [ultra_res]
    ; movq xmm1, [two]
    ; mov rax, 2 
    ; mov rdi, true_output
    ; call printf
    

   


    ; movq xmm0,  [result]
    ; fmul st0, st1
    ;  fstp [result]

  
  mov rax, 60
  mov rdi, 0
  syscall


correct:
push rax
push rcx
ffree st0
ffree st1
    movq xmm0, [x]
    movq xmm1, [two]
    mov rax,2  
    call pow 
    movq xmm4, xmm0  ; xmm4 = x^2
    mov rax, 1
    call exp
    movq xmm3, xmm0 ; xmm0=xmm3 = e^x^2
    movq [result], xmm4
    fld [result]
    fld [two]
    fmul st0, st1
    ffree st1

    fld1 
    fadd st0, st1
    movq [result], xmm3
    fld [result]
    fmul st0, st1
    fstp [result]
    movq xmm0, [result]
pop rcx
pop rax
    ret
;

pow_2n_div_fact:
push rax
push rcx
    ffree st0
    ffree st1

    fld [x]
    ; fmul[x]

    mov rax, [n]
    cmp [n], 0


    jne .cont
    ffree st0
    fld [one]
    jmp .end
    .cont:
    push rbx
    push rdx
    mov rbx, 2
    xor rdx, rdx
    mul rbx
    pop rdx
    pop rbx


    .mlp:
        fmul [x]
        dec rax
        cmp rax, 1
    jg .mlp

    mov rax, [n]
    mov [cur_n], rax
    .mlp2:
    ;     ; call new_line
        fild [cur_n]

        fdiv st1, st0

        fxch st1
        ffree st1
        ; call new_line
        dec [cur_n]
    
        cmp [cur_n], 1
    
    jg .mlp2
.end:
    ; fstp [result]  ; пока что оставляю в st0
    pop rcx
    pop rax
    ret

sum_for_n:
push rcx
    cmp [n], 0
    jg .con
    mov rax, [one]
    mov [ultra_res], rax
    jmp .end

    .con:
    ffree st0
    ffree st1
    mov rax, [one]
    mov [ultra_res], rax
    
    
    .mlp:
        ; fld [zero]
        ; fld [zero]
        call pow_2n_div_fact ;st0 ans
        
        fld1  ;st0 = 1, st1 = ans
        fild [n] ; st0=n, st1=1, st2=ans
        fmul [two]
        fadd st0, st1
        fmul st0, st2
        ffree st1
        ffree st2



        fadd [ultra_res] ;st0 total ans
        fstp [ultra_res]
        
        
        ; ffree st1


        ; fadd st2, st0
        ; ffree st0
        ; ffree st1
        dec [n]
        cmp [n], 0
        jg .mlp
; fxch st5
        .end:
; 
pop rcx
    ret
