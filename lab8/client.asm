;;client_2.asm
format elf64
public _start

include 'func.asm'

section '.data' writeable
take_msg db 'Ваша карта: %d, сумма %d', 0xA,0
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'Successful connect', 0xa, 0
  msg_4 db 'Error connect', 0xa, 0
  msg_enter db 'Вы присоединились к игре. Отправьте T, чтобы взять карту, или S, чтобы остановиться.', 0xa, 0
  number dq 0
  quit_msg db 'Вы покинули игру!', 0xA, 0
  msg_lost db 'Переполнение! Вы проиграли.', 0xA, 0
  reading_msg db '_r_', 0
  
  ender db 'Ending connection', 0xA, 0
  random_resp db 'Ваше число - %d', 0xA, 0
  stop_msg db 'Вы остановились на счете %d', 0xA,0
  RANDOM dq 0
  quit db 'Q',0
  MAX dq 12
  MIN dq 3
  f  db "/dev/urandom",0
  sm1 dw 0, -1, 4096 
  sm2 dw 0,  1, 4096   
  ids dq 0
  balance dq 0
section '.bss' writable
	random_desc rq 1
  buffer1 rb 100
  buffer2 rb 100
  server rq 1

  

struc sockaddr_client
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0    ; port 55556
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

addrstr_client sockaddr_client 
addrlen_client = $ - addrstr_client
  
struc sockaddr_server 
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x3d9     ; port 55555
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

addrstr_server sockaddr_server 
addrlen_server = $ - addrstr_server

section '.text' executable
	
extrn printf
_start:

   mov rdi, f
   mov rax, 2 
   mov rsi, 0o
   syscall 
   mov [random_desc], rax


  ;  mov rax, 0 ;
  ;   mov rdi, [random_desc]
  ;   mov rsi, number
  ;   mov rdx, 1
  ;   syscall
  
    ; mov rax, [number]
    ; xor rdx, rdx
    ; mov rcx, 100
    ; div rcx
    ; inc rdx
    ; add [addrstr_client+2], rdx
    ; xor rdx,rdx
    ; mov rax, [addrstr_client+2]
    ; mov rsi, buffer1
    ; call number_str
    ; call print_str
    ; call exit


  ;  call take_card
  ;   call exit
    
   
  ;   call exit
    ;;Создаем семафор
    mov rdi, 0
    mov rsi, 1
    mov rdx, 438 ;;0o666
    or rdx, 512
    mov rax, 64
    syscall
    
    mov [ids], rax
    
    ;;Переводим семафор в состояние готовности
    mov rdi, [ids] ;дескриптор семафора
    mov rsi, 0     ;индекс в массиве
    mov rdx, 16    ;выполняемая команда
    mov r10, 0   ;начальное значение
    mov rax, 66
    syscall
    


    ;;Создаем сокет клиента
    mov rdi, 2 ;AF_INET - IP v4 
    mov rsi, 1 ;SOCK_STREAM
    mov rdx, 6 ;TCP
    mov rax, 41
    syscall
    cmp rax, 0
    je _bind_error


    ;;Сохраняем дескриптор сокета клиента
    mov r9, rax
    mov [server], rax
    
       
    ;;Связываем сокет с адресом
    
    mov rax, 49              ; SYS_BIND
    mov rdi, r9              ; дескриптор сервера
    mov rsi, addrstr_client  ; sockaddr_in struct
    mov rdx, addrlen_client  ; length of sockaddr_in
    syscall

    ;; Проверяем успешность вызова
    cmp        rax, 0
    jl         _bind_error
    
    mov rsi, msg_2
    call print_str
    
    ;;Подключаемся к серверу
    mov rax, 42 ;sys_connect
    mov rdi, r9 ;дескриптор
    mov rsi, addrstr_server 
    mov rdx, addrlen_server
    syscall
    
    cmp rax, 0
    jl  _connect_error

    mov rax, 57
     syscall
     cmp rax,0
     je _read
     
     mov rax, 57
     syscall
     cmp rax,0
     je _write

      mov rsi, msg_enter
     call print_str

    .main_loop:
    mov rdi, [ids]
    mov rsi, sm1
    mov rdx,1
    mov rax, 65
    syscall
    mov rsi, ender
    call print_str
    .end:
    call quit_game

    mov rdi, [ids]
    mov rsi, sm2
    mov rdx,1
    mov rax, 65
    syscall
    ; ;;Закрываем чтение, запись из клиентского сокета
    mov rax, 48
    mov rdi, r9
    mov rsi, 2
    syscall
          
    ;;Закрываем клиентский сокет
    mov rdi, r9
    mov rax, 3
    syscall
    
    call exit

    
_bind_error:
   mov rsi, msg_1
   call print_str
   call exit
   
_connect_error:
   mov rsi, msg_4
   call print_str
   call exit

_read:

    ; mov rsi, reading_msg
    ; call print_str
      mov rax, 0 ;номер системного вызова чтения
      mov rdi, r9 ;загружаем файловый дескриптор
      mov rsi, buffer1 ;указываем, куда помещать прочитанные данные
      mov rdx, 100 ;устанавливаем количество считываемых данных
      push rsi
      ; mov rsi, msg_3
      ; call print_str
      ; pop rsi
      syscall ;выполняем системный вызов read
      ; mov rsi, msg_3
      ; call print_str
      ; pop rsi
    ;   ;;Если клиент ничего не прислал, продолжаем
      ; mov rsi, buffer1
      ; call number_str
      ; call print_str
      cmp rax, 0
      je _read    
      ; jne _read
      

      mov rdi, buffer1
      push rcx
      call print_str
      pop rcx
      call new_line



      
    ;   ;;Очищаем буффер, чтобы он не хранил старые значения
      mov rcx, 100
      mov rax, 0
      .lab:
        mov [buffer1+rcx], 0
      loop .lab 
jmp _read

_write:
    
    mov rsi, buffer2
    call input_keyboard
    
    cmp byte [buffer2], 'Q'
    
    je _start.end

    cmp byte [buffer2], 'T'
    jne .next1
    call take_card
    jmp .next2
    


    .next1:
    cmp byte [buffer2], 'S'
    jne .next2
    call stop_take
    
    ; jmp _write
    .next2:
    
    ;;Отправляем сообщение на сервер
    mov rax, 1
    mov rdi, [server]
    mov rsi, buffer2
    mov rdx, 100
    syscall

      ; mov rcx, 100
      ; .lab:
      ;   mov [buffer2+rcx], 0
      ; loop .lab 
jmp _write


take_card:
    mov rax, 0 ;
    mov rdi, [random_desc]
    mov rsi, number
    mov rdx, 1
    syscall
    mov rax, [MAX]
    sub rax, [MIN]
    mov rcx, rax ;rcx=5
    mov rax, [number] ;rax = rand
    xor rdx, rdx
    div rcx
    mov rax, rdx
    add rax, [MIN]
    mov [RANDOM], rax
    mov rdi, take_msg
    mov rsi, [RANDOM]
    add [balance], rax
    cmp [balance], 22
    jl .nnnext
    mov rsi, msg_lost
    call print_str
    mov [balance], 0
    jmp wh_l

    .nnnext:
    mov rdx, [balance]
    push rax
    call printf
    pop rax
    mov rax, [RANDOM]
    wh_l:
    mov BYTE [buffer2], '!'
    mov BYTE [buffer2+1], al
    mov BYTE [buffer2+2], 0
    
    
    ret

stop_take:
    
    mov rdi, stop_msg
    mov rsi, [balance]
    push rax
    call printf
    pop rax
    mov BYTE [buffer2], '#'
    mov BYTE [buffer2+1], 0
    mov [balance], 0
    ret

quit_game:
    mov rdi, quit_msg
    push rax
    call printf
    pop rax
    mov BYTE [buffer2], '|'
    mov BYTE [buffer2+1], 0
    ret