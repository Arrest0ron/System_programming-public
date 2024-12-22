;;client_2.asm

format elf64
public _start
include 'func.asm'

section '.data' writeable
  
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'Successful connect', 0xa, 0
  msg_4 db 'Error connect', 0xa, 0

section '.bss' writable
	
  buffer1 rb 100
  buffer2 rb 100
  

struc sockaddr_client
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x4d9     ; port 55556
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
	
_start:

    ;;Создаем сокет клиента
    mov rdi, 2 ;AF_INET - IP v4 
    mov rsi, 1 ;SOCK_STREAM
    mov rdx, 6 ;TCP
    mov rax, 41
    syscall
    
    ;;Сохраняем дескриптор сокета клиента
    mov r9, rax
    
       
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
    .main_loop:
     jmp .main_loop
    
    ;;Закрываем чтение, запись из клиентского сокета
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
      mov rax, 0 ;номер системного вызова чтения
      mov rdi, r9 ;загружаем файловый дескриптор
      mov rsi, buffer1 ;указываем, куда помещать прочитанные данные
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
        mov [buffer1+rcx], 0
      loop .lab 
jmp _read

_write:
     mov rsi, buffer2
     call input_keyboard
    
    ;;Отправляем сообщение на клиенту
    mov rax, 1
    mov rdi, r9
    mov rsi, buffer2
    mov rdx, 100
    syscall
jmp _write