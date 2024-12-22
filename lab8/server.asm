;;server_3.asm

format elf64
public _start

extrn printf


include 'func.asm'

section '.data' writeable
  
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'New connection on server',0xA, 0
  msg_4 db 'Successfull listen', 0xa, 0
  ping_msg db '[pingall]', 0xA, 0
  from_msg db '[usr%d]: '

  automated_response db 'ping client', 0xA, 0
  address dq 0
  new_status db 0

  ids dq 0
  val dq 0
    sm1 dw 0, -1, 4096 
   sm2 dw 0, 1, 4096   
  
  
section '.bss' writable
	
  buffer rb 100
  buffer_help rb 200
  read_buffer rb 100
  descriptors dq 2
  my_status dq 0

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
      mov rsi, read_buffer ;указываем, куда помещать прочитанные данные
      mov rdx, 100 ;устанавливаем количество считываемых данных
      syscall ;выполняем системный вызов read


      
      
      ;;Если клиент ничего не прислал, продолжаем
      cmp rax, 0
      je _read     
      mov rdi, from_msg
      mov rsi, r12
      call printf
      
      mov rsi, read_buffer
      call print_str
      call new_line
      
      ;;Очищаем буффер, чтобы он не хранил старые значения
      mov rcx, 100
      mov rax, 0
      .lab:
        mov [read_buffer+rcx], 0
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
  ;   xor rax, rax
  ; mov rdi, [address]
  
  ; cmp BYTE [rdi+1],0
  ;   jle _write
        ;;Запираем семафор


    mov rdi, [ids]
    mov rsi, sm1
    mov rdx,1
    mov rax, 65
    syscall
    
    ; dec BYTE [rdi+1]

    mov rsi, ping_msg
    call print_str

    ; xor rax, rax
    ; mov rdi, [address]
    ; mov al, [rdi+1]
    ; mov rsi, buffer
    ; call number_str
    ; call print_str
    ; call new_line


    mov rax, 1
    mov rdi, r12
    mov rsi, automated_response
    mov rdx, 13
    syscall

      ; mov rdi, [address]


    



jmp _write

      
_input:

    mov rsi, buffer
    call input_keyboard
    xor rax, rax
    ; mov rdi, [address]
    ; mov BYTE al, [rdi]

    ; mov [rdi+1], al
     ;;Открываем семафор
    ; mov rdi, [ids]
    ; mov rsi, sm2
    ; mov rdx,0
    ; mov rax, 65
    ; syscall
     ;;Открываем семафор
    mov rdi, [ids]
    mov rsi, sm2
    mov rdx,1
    mov rax, 65
    syscall
    mov rdi, [ids]
    mov rsi, sm2
    mov rdx,1
    mov rax, 65
    syscall
    ; mov al, [new_status]
    ; call number_str
    ; call print_str
    ;         mov rdi, [address]
    ; mov rax, [rdi]
    ; call number_str
    ; call print_str
jmp _input

