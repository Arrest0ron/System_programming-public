;;server_3.asm

format elf64
public _start

extrn printf
extrn mydelay

include 'func.asm'

section '.data' writeable
  sent_gain_msg db '_C!_', 0xA,0
  sent_stop_msg db '_C#_', 0xA,0
  sent_win_msg db '_C^_', 0xA,0
  read_msg db '_r', 0

  debug_sem_msg db 'Текущее значение семафора: ',0
  debug_atomized_msg db 'Текущее значение атомарного счетчика: ',0

  DBG_to_others db 'Отправляю другим сообщение о взятии...', 0

  user_caused db '_event # caused by %d', 0xA, 0

  sending_dt db ' sent to %d', 0xA, 0
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'New connection on server',0xA, 0
  score_msg db 'Игрок %d закончил игру со счетом %d', 0xA, 0
  msg_4 db 'Successfull listen', 0xa, 0
  reset_amount_msg db 'Перезапускаем игру для %d игроков', 0xA, 0
  win_msg db '>Победил пользователь %d со счетом %d<', 0xA, 0
  new_game_msg db 'Новая игра началась!', 0xA, 0
  ping_msg db '[ping%d]', 0xA, 0
  from_msg db '[usr%d]: ', 0xA, 0
  other_takes_msg db '<Игрок %d взял карту %d, его счет %d>', 0xA, 0
  other_stop_msg db '<Игрок %d остановился на счете %d>', 0xA, 0
  other_lost_msg db '<Игрок %d проиграл со счетом %d>', 0xA, 0
  other_connected db '<Присоединился новый игрок - usr%d>', 0xA, 0
  left_players_msg db '<Осталось %d игроков>', 0xA, 0
  endgame_msg db 'Игра окончена. Подсчет результатов...', 0xA,0

  automated_response db 'ping client', 0xA, 0
  results_msg db 0xA, '____________ Результаты игры ____________', 0xA,0
results2_msg db 0xA,  '______________ Начало игры ______________', 0xA,0
  random_resp db 'Ваше число - %d', 0xA, 0
  new_player_stats db 'Имеется %d игроков, %d - активно.',0xA,0  
  nowin db 'Победителей нет!', 0xA, 0     
  user_left_msg db 'Игрок %d покинул игру, осталось %d игроков.', 0xA,0
  cards_scores_players_current dq 0 ; +0-63 scores (up to 64 players) , +64 - total players
  new_status db 0
  enders dq 0  ; +0-63 enders, +64 - current_ended
  inp_msg db '_in_', 0xA, 0
  message_to_all dq  0 ;+0-64 - msg
  max_to21 dq 0, 0
  stack_alignment db 0
  temp db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  DBG_start_sem_loop db 'Пользователь написал, начинаю увеличивать семафор', 0xA,0
  DBG_end_sem_loop db 'Завершено!', 0xA,0
  DBG_amount_msg db 'Всего: %d, в игре: %d, не завершило ход: %d.', 0xA, 0
  DBG_start_copy db 'Пользователь написал, начинаю копировать сообщение', 0xA,0
  DBG_end_copy db 'Завершено', 0xA,0
  DBG_reduce_sem db 'Отправлено сообщение, уменьшаю семафор', 0xA,0
  DBG_message_cleared  db 'Буфер отправления очищен', 0xA,0
  


  ids dq 0
  val dq 0
    sm1 dw 0, -1, 4096 
   sm2 dw 0, 1, 4096   


  
  
section '.bss' writable
	
  buffer rb 100
  buffer_help rb 200

  read_buffer rb 100
  write_buffer rb 100

  

  random_desc rq 1
;;Структура для клиента
  struc sockaddr_in
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x4d9     ; port 
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
    mov rsi, 1024   ;задаем размер области памяти
    mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
    mov r10, 0x21  ;задаем режим MAP_ANONYMOUS|MAP_SHARED
    mov r8, -1   ;указываем файловый дескриптор null
    mov r9, 0     ;задаем нулевое смещение
    mov rax, 9    ;номер системного вызова mmap
    syscall

    
    
    ;;Сохраняем адрес памяти
    mov [cards_scores_players_current], rax
    mov [enders], rax
    add [enders], 64
    mov [message_to_all], rax
    add [message_to_all], 64
    add [message_to_all], 64


    mov rcx, 1023
    mov rsi, [cards_scores_players_current]
    .initial_clear:
        mov BYTE [rsi+rcx], 0
        dec rcx
        cmp rcx, -1
        jne .initial_clear


        

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

    mov rsi, [cards_scores_players_current]
    mov BYTE [rsi+992], 0
    mov BYTE [rsi+1000], 0
    mov BYTE [rsi+1008], 0
    mov BYTE [rsi+1016], 0

    lock inc BYTE [rsi+992]     ; СЕМАФОР
    
    ;;Главный цикл ожидания подключений
    .main_loop:
      mov rax, 43
      mov rdi, r9
      mov rsi, 0
      mov rdx, 0
      syscall
      ;;Сохраняем дескриптор сокета клиента
      mov r12, rax
      mov rsi, msg_3
      call print_str
      
      mov rsi, [cards_scores_players_current]

      

      ; lock inc BYTE [rsi+992]     ; СЕМАФОР
      call debug_atomized

      lock inc BYTE [rsi+1000]    ; ВСЕ СУЩЕСТВОВАВШИЕ ИГРОКИ
      lock inc BYTE [rsi+1008]    ; АКТУАЛЬНОЕ ЧИСЛО ИГРОКОВ
      lock inc BYTE [rsi+1016]    ; ЧИСЛО НЕ ЗАВЕРШИВШИХ ХОД

      
      mov rdi, other_connected 
      xor rdx, rdx
      mov dl, [rsi+1000]
      
      mov rsi, rdx
      call safe_printf

      call debug_amounts
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


     .clean_memory:
    ;; выполняем системный вызов munmap, освобождая память
    mov rdi, [cards_scores_players_current]
    mov rsi, 1024
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

      mov rsi, [cards_scores_players_current]
      mov rcx, [rsi+1008]

      mov rsi, DBG_start_sem_loop
      call print_str
      .semloop:

          mov rsi, [cards_scores_players_current]
          lock inc BYTE [rsi+992]
      loop .semloop

      mov rsi, DBG_end_sem_loop
      call print_str

      call debug_atomized
      call debug_amounts

    
      ; mov rsi, [cards_scores_players_current]
      ; mov rbx, read_buffer
      


      
      ;; ПРОВЕРКА НА ВЗЯТИЕ КАРТЫ
      cmp BYTE [read_buffer], '!'
      jne .nocard

        mov rdi, other_takes_msg   ;строка для ввода

        xor rsi, rsi
        xor rax, rax
        mov BYTE al, [read_buffer]
        mov rsi, rax
        xor rax, rax
        call safe_printf
        mov rdi, [message_to_all]
        mov rax, r12

        mov BYTE [rdi+0], al         ; кто взял
        mov BYTE  [rdi+1], '!'       ; взял!
        mov BYTE al, [read_buffer+1] 
        mov BYTE [rdi+2], al         ; сколько 
        mov rbx, r12
        mov rsi, [cards_scores_players_current]
        add [rsi+rbx], al
        mov rax, [rsi+rbx]
        mov BYTE [rdi+3], al        ; баланс взявшего 
        mov BYTE [rdi+4], 0          ; терминатор
        jmp _read
        
      .nocard:


      ;; ПРОВЕРКА НА ОСТАНОВКУ
      cmp BYTE [read_buffer], '#'
      jne .nostop

        mov rdi, other_stop_msg   ;строка для ввода

        xor rsi, rsi
        xor rax, rax
        mov BYTE al, [read_buffer]
        mov rsi, rax
        xor rax, rax
        call safe_printf
                mov rdi, [message_to_all]
        mov rax, r12

        mov BYTE [rdi+0], al         ; кто остановился
        mov BYTE  [rdi+1], '#'       ; остановился!
        mov BYTE al, [read_buffer+1] 
        mov rbx, r12
        mov rsi, [cards_scores_players_current]
        add [rsi+rbx], al
        mov rax, [rsi+rbx]
        mov BYTE [rdi+2], al        ; баланс остановившегося
        mov BYTE [rdi+3], 0          ; терминатор
        jmp _read

      .nostop:
      






      mov rsi, read_buffer
      call print_str
      call new_line
      mov rsi, DBG_start_copy
      call print_str

    mov rsi, [message_to_all]
    mov rcx, 64

    .copy_after_msg:
        ; mov BYTE [rsi+rcx], 0
        mov BYTE bl, [read_buffer+rcx]
        mov BYTE [rsi+rcx+1], bl
        dec rcx
        cmp rcx, -1
        jne .copy_after_msg

    xor rax, rax
    mov rbx, r12
    mov al, bl
    ; mov rsi, temp
    ; call number_str
    ; call print_str

    mov rsi, [message_to_all]
    mov BYTE [rsi], al
          ; mov rax, 1
          ; mov rdi, r12
          ; mov rsi, [message_to_all]
          ; mov rdx, 64
          ; syscall



jmp _read

_write:
  mov rdi, 50
  call mydelay

  ; mov rsi, message_to_all
  ; call print_str
   

    mov rsi, [message_to_all]
    cmp BYTE [rsi], 0
    je _write

    mov rsi, [cards_scores_players_current]
    mov al, 1
    lock cmpxchg BYTE [rsi+992], al
    je .empty


    mov rsi, DBG_reduce_sem
    call print_str
    call new_line

    mov rsi, [cards_scores_players_current]
    lock dec BYTE [rsi+992]

 

    call debug_atomized



     mov rdi, user_caused
     mov rsi, r12
    call safe_printf

  xor rax, rax
  xor rbx, rbx
  mov rbx, r12
  mov al, bl
  mov rsi, [message_to_all]
  cmp BYTE [rsi], al
  je _write


    mov rax, 1
    mov rdi, r12
    mov rsi, [message_to_all]
    mov rdx, 64
    syscall
jmp _write

    .empty:
    mov rsi, [message_to_all]
    mov rcx, 64
    .clear_after_lock:
        mov BYTE [rsi+rcx], 0
        dec rcx
        cmp rcx, -1
        jne .clear_after_lock
    mov rsi, DBG_message_cleared
    call print_str

jmp _write


; rdi = форматная строка
; остальные аргументы printf передаются как обычно
safe_printf:
    ; Проверяем текущее выравнивание стека
    test rsp, 0xF
    jz .aligned
    
    ; Если стек не выровнен, сохраняем факт коррекции
    mov byte [stack_alignment], 1
    push rax    ; Корректируем стек (теперь он выровнен)
    jmp .call_printf
    
.aligned:
    mov byte [stack_alignment], 0
    
.call_printf:
    ; Сохраняем все используемые регистры
    push rdi
    push rsi
    push rdx
    push rcx
    push r8
    push r9
    push r10
    push r11
    
    ; Вызов printf
    xor eax, eax    ; 0 floating point args
    call printf
    
    ; Восстанавливаем регистры
    pop r11
    pop r10
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    
    ; Проверяем, делали ли мы коррекцию
    cmp byte [stack_alignment], 1
    jne .done
    
    ; Если делали коррекцию - убираем ее
    pop rax
    mov byte [stack_alignment], 0
    
.done:
    ret



debug_semop:
    ; Сохраняем регистры
    push rdi
    push rsi
    push rdx
    
    ; Выводим отладочное сообщение
    mov rsi, debug_sem_msg
    call print_str
    
        mov rdi, [ids]  ; Дескриптор семафора
    mov rsi, 0      ; Индекс семафора
    mov rdx, 12     ; Команда GETVAL
    xor r10, r10    ; Четвертый аргумент не используется
    mov rax, 66     ; Системный вызов semctl
    syscall
    mov rsi, temp
    call number_str
    call print_str
    call new_line
    
    ; Восстанавливаем регистры
    pop rdx
    pop rsi
    pop rdi
    
    ret

debug_atomized:
    ; Сохраняем регистры
    push rdi
    push rsi
    push rdx
    
    ; Выводим отладочное сообщение
    mov rsi, debug_atomized_msg
    call print_str
    mov rsi, [cards_scores_players_current]
    mov BYTE al, [rsi+992]

    mov rsi, temp
    call number_str
    call print_str
    call new_line
    
    ; Восстанавливаем регистры
    pop rdx
    pop rsi
    pop rdi
    
    ret


debug_amounts:
  push rax
  push rsi
  push rdx
  push rcx
  push rbx
  push rdi
 
  mov rbx, [cards_scores_players_current]
  mov rsi, [rbx+1000]
  mov rdx, [rbx+1008]
  mov rcx, [rbx+1016]
  mov rdi, DBG_amount_msg

  call safe_printf

  pop rdi
  pop rbx
  pop rcx
  pop rdx
  pop rsi
  pop rax
  
  ret
