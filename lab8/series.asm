format ELF64
;fasm series.asm &&  ld series.o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lm -o series && ./series

include 'func.asm'
extrn printf
extrn exp
extrn pow

section '.data' writable
    top_out db "X         Delta         Diff          N", 0xA, 0
    delta_out db "%.8f    ", 0
    X_out db "%.2f      ", 0
    N_out db "%d" ,0xA, 0
    true_output db "True number: %.15f for x: %.2f", 0xA, 0
    calc_output db "Calc number: %.15f for x: %.2f", 0xA, 0
    e_real dq 2.71828182846
    delta dq 0.0000001
    diff dq 0.0

    zero dq 0.0
    one dq 1.0
    two dq 2.0
    three dq 3.0

    numbers dq 0.0, 0.25, 0.5,0.75,  1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5
    counter dq 0
    evaluation_n dq 0
    
    x dq 0.0
    n dq 1
    cur_n dq 0
    
    
    ; two dq 2.0

section '.bss' writable
    true_res rq 10
    result rq 10
    ultra_res rq 10
section '.text' executable
public _start
_start:
    mov rsi, top_out
    call print_str
    .mlp2:
    .ench:
    inc [evaluation_n]
            mov rbx, [counter]
            mov rax, [numbers+8*rbx]
            mov [x], rax
            call correct ;xmm0 correct
            ; movq xmm1, [x]
            ; mov rax, 2
            ; mov rdi, true_output
            ; call printf
            mov rbx, [counter]
            mov rax, [numbers+8*rbx]
            mov [x], rax
            mov rax, [evaluation_n]
            mov [n], rax
            call sum_for_n
            ; movq xmm0, [ultra_res]
            ; mov rbx, [counter]
            ; movq xmm1, [numbers+8*rbx]
            ; mov rax, 2 
            ; mov rdi, calc_output
            ; call printf
            finit
            ffree st0
            ffree st1
            fld [true_res]
            fsub [ultra_res]
            fabs 
            fst [diff]
            fld [delta]
            finit 
            fld [delta]
            fld [diff]
            fcomip st0, st1
            ja .ench
            ; movq xmm0, [true_res]
            ; movq xmm1, [x]
            ; mov rax, 2
            ; mov rdi, true_output
            ; call printf
            ; movq xmm0, [ultra_res]
            mov rbx, [counter]
            movq xmm0, [numbers+8*rbx]
            mov rax, 2 
            mov rdi, X_out
            call printf

            movq xmm0, [delta]
            mov rax, 1
            mov rdi, delta_out
            call printf

            movq xmm0, [diff]
            mov rax, 1
            mov rdi, delta_out
            call printf

            mov rsi, [evaluation_n]
            mov rdi, N_out
            mov rax, 1
            call printf
                inc [counter]
                cmp [counter], 11
                jl .mlp2

  
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
    fstp [true_res]
    movq xmm0, [true_res]
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
        dec [n]
        cmp [n], 0
        jg .mlp
        .end:
; 
pop rcx
    ret
