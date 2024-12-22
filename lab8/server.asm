;;server_3.asm

format elf64
public _start
include 'func.asm'

section '.data' writeable
  
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'New connection on server',0xA, 0
  msg_4 db 'Successfull listen', 0xa, 0
  automated_response db 'ping client', 0xA, 0
  address dq 0
  new_status db 0
  
  
section '.bss' writable
	
  buffer rb 100
  buffer_help rb 200
  descriptors dq 2

;;Структура для клиента
  struc sockaddr_in
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x3d9     ; port 55555
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

  addrstr sockaddr_in 
  addrlen = $ - addrstr

section '.text' executable
	
_start:
  
      ;;Первый процесс создает разделяемую память
    mov rdi, 0    ;начальный адрес выберет сама ОС
    mov rsi, 2    ;задаем размер области памяти
    mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
    mov r10, 0x21  ;задаем режим MAP_ANONYMOUS|MAP_SHARED
    mov r8, -1   ;указываем файловый дескриптор null
    mov r9, 0     ;задаем нулевое смещение
    mov rax, 9    ;номер системного вызова mmap
    syscall
    
    ;;Сохраняем и печатаем адрес памяти
    mov [address], rax

    ;;Создаем сокет
    mov rdi, 2 ;AF_INET - IP v4 
    mov rsi, 1 ;SOCK_STREAM
    mov rdx, 6 ;TCP
    mov rax, 41
    syscall
    
    ;;Сохраняем дескриптор сокета
    mov r9, rax
    
       
    ;;Связываем сокет с адресом
    
    mov rax, 49              ; SYS_BIND
    mov rdi, r9              ; дескриптор сервера
    mov rsi, addrstr        ; sockaddr_in struct
    mov rdx, addrlen         ; length of sockaddr_in
    syscall

    ;; Проверяем успешность вызова
    cmp        rax, 0
    jl         _bind_error
    
    mov rsi, msg_2
    call print_str
    
    ;;Запускаем прослушивание сокета
    mov rax, 50 ;sys_listen
    mov rdi, r9 ;дескриптор
    mov rsi, 10  ; количество клиентов
    syscall
    cmp rax, 0
    jl  _bind_error

    mov rax, 57
     syscall
   
     cmp rax,0
     je _input
    
    ;;Главный цикл ожидания подключений
    .main_loop:
      
      ;;
      mov rax, 43
      mov rdi, r9
      mov rsi, 0
      mov rdx, 0
      syscall

      ;;Сохраняем дескриптор сокета клиента
      mov r12, rax

      mov rsi, msg_3
      call print_str
      mov rdi, [address]
      inc BYTE [rdi]
      mov rsi, buffer
      xor rax, rax
      mov rax ,[address]
      call number_str
      call print_str

     ;;Делаем fork for read
   
     mov rax, 57
     syscall
   
     cmp rax,0
     je _read
     
     mov rax, 57
     syscall
   
     cmp rax,0
     je _write
      
     jmp .main_loop
        ;; выполняем системный вызов munmap, освобождая память
    mov rdi, [address]
    mov rsi, 1
    mov rax, 11
    syscall
    call exit
    
_bind_error:
   mov rsi, msg_1
   call print_str
   call exit
   
_read:
      mov rax, 0 ;номер системного вызова чтения
      mov rdi, r12 ;загружаем файловый дескриптор
      mov rsi, buffer ;указываем, куда помещать прочитанные данные
      mov rdx, 100 ;устанавливаем количество считываемых данных
      syscall ;выполняем системный вызов read


      
      
      ;;Если клиент ничего не прислал, продолжаем
      cmp rax, 0
      je _read     
      call print_str
      call new_line
      
      ;;Очищаем буффер, чтобы он не хранил старые значения
      mov rcx, 100
      mov rax, 0
      .lab:
        mov [buffer+rcx], 0
      loop .lab 
jmp _read

_write:

    ; mov rsi, buffer_help
    ; mov rax, r12
    ; call number_str
    ; call print_str
    ; mov rsi, buffer
    ; call input_keyboard
    
    ;;Отправляем сообщение на клиенту
    xor rax, rax
  mov rdi, [address]
  cmp BYTE [rdi+1],0
    je _write
    cmp BYTE [rdi+1],0
    jb _write

    mov rax, 1
    mov rdi, r12
    mov rsi, automated_response
    mov rdx, 13
    syscall
      mov rdi, [address]
    dec  BYTE [rdi+1]


jmp _write

      
_input:

    mov rsi, buffer
    call input_keyboard
    xor rax, rax
    mov rdi, [address]
    mov BYTE al, [rdi]

    mov [rdi+1], al

    ; mov al, [new_status]
    ; call number_str
    ; call print_str
    ;         mov rdi, [address]
    ; mov rax, [rdi]
    ; call number_str
    ; call print_str
jmp _input

