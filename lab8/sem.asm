format elf64
public _start

section '.data' writable
    val dq 1
    s1 db '1234', 0xa, 0
    sm1 dw 0, -1, 4096  ; Semaphore operation structure to decrement
    sm2 dw 0, 1, 4096   ; Semaphore operation structure to increment

section '.bss' writable
    buffer rb 100
    ids rq 1
    place rb 1

section '.text' executable
_start:
    ; Create a semaphore set with one semaphore
    mov rdi, 0          ; Semaphore key (IPC_PRIVATE)
    mov rsi, 1          ; Number of semaphores
    mov rdx, 438        ; Permissions (0666)
    or rdx, 512         ; IPC_CREAT
    mov rax, 64         ; syscall number for semget
    syscall
    mov [ids], rax      ; Store the semaphore ID

    ; Initialize the semaphore value to 0
    mov rdi, [ids]      ; Semaphore ID
    mov rsi, 0          ; Semaphore number (0 for the first semaphore)
    mov rdx, 16         ; Command (SETVAL)
    mov r10, 0          ; Initial value
    mov rax, 66         ; syscall number for semctl
    syscall

    ; Wait on the semaphore (this will block the main process)
    mov rdi, [ids]      ; Semaphore ID
    mov rsi, sm1        ; Semaphore operation structure
    mov rdx, 1          ; Number of operations
    mov rax, 65         ; syscall number for semop
    syscall

    ; Exit the program
    mov rax, 60         ; syscall number for exit
    xor rdi, rdi        ; exit code 0
    syscall
