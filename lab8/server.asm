;;server_3.asm

format elf64
public _start

extrn printf


include 'func.asm'

section '.data' writeable
  sent_gain_msg db '_C!_', 0xA,0
  sent_stop_msg db '_C#_', 0xA,0
  sent_win_msg db '_C^_', 0xA,0

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


  ids dq 0
  val dq 0
    sm1 dw 0, -1, 4096 
   sm2 dw 0, 1, 4096   

    wsm1 dw 1, -1, 4096 
   wsm2 dw 1, 1, 4096   
  
  
section '.bss' writable
	
  buffer rb 100
  buffer_help rb 200
  read_buffer rb 101

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


    ;;Создаем семафор
    mov rdi, 0
    mov rsi, 2
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

        ;;Переводим семафор в состояние готовности
    mov rdi, [ids] ;дескриптор семафора
    mov rsi, 1     ;индекс в массиве
    mov rdx, 16    ;выполняемая команда
    mov r10, 0   ;начальное значение
    mov rax, 66
    syscall

      ;;Первый процесс создает разделяемую память
    mov rdi, 0    ;начальный адрес выберет сама ОС
    mov rsi, 512    ;задаем размер области памяти
    mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
    mov r10, 0x21  ;задаем режим MAP_ANONYMOUS|MAP_SHARED
    mov r8, -1   ;указываем файловый дескриптор null
    mov r9, 0     ;задаем нулевое смещение
    mov rax, 9    ;номер системного вызова mmap
    syscall
    
    ;;Сохраняем адрес памяти
    mov [cards_scores_players_current], rax
    mov [enders], rax
    add [enders], 65
    mov [message_to_all], rax
    add [message_to_all], 65
    add [message_to_all], 65

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
      mov rax, 43
      mov rdi, r9
      mov rsi, 0
      mov rdx, 0
      syscall
      ;;Сохраняем дескриптор сокета клиента
      mov r12, rax
      mov rsi, msg_3
      call print_str
      mov rdi, [cards_scores_players_current]
      inc byte [rdi+64]  ;players count
      mov rdi, [enders]
      inc BYTE [rdi+64]

      mov rdi, [enders]
      xor rax, rax
      mov al, [rdi+64]
      mov rdx, rax
      mov rdi, [cards_scores_players_current]
      mov al, [rdi+64]
      mov rsi, rax
      ; mov rsi, 0
      ; mov rdx, 0
      mov rdi, new_player_stats
      push rsi 
      push rcx
      push rax
      push rdx
      push r9
      ; push r10
      push r12
      call printf
      pop r12
      ; pop r10
      pop r9
      pop rdx
      pop rax
      pop rcx
      pop rsi
      
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

      push rdx
      push rax
      push r12  ;user
      push rcx
                                ;       mov rdi, user_caused
                                ; mov rsi, r12
                                ; call printf
      pop rcx
      pop r12
      pop rax
      pop rdx

      cmp BYTE [read_buffer], '!'
      jne .next12
      mov rbx, [cards_scores_players_current]
      xor rax, rax
      mov al, [read_buffer+1]
      add BYTE [rbx+r12], al
      mov rdi, other_takes_msg
      xor rax, rax
      mov al, [read_buffer+1]
      mov rsi, r12
      mov rdx, rax
      mov rbx, [cards_scores_players_current]
      xor rcx, rcx
      mov cl, BYTE [rbx+r12]
      push rdx
      push rax
      push r12  ;user
      push rcx
      ; push rax
      call printf
      pop rcx
      pop r12
      pop rax
      pop rdx
      mov rax, rcx
      call to_all_takes        ;/////////////////////////////
      ; pop rax
      mov rbx, [cards_scores_players_current]
      xor rax, rax
      mov al, [read_buffer+1]
      
      cmp BYTE [rbx+r12], 21
      jl .nnext
      cmp BYTE [rbx+r12], 21
      je .nnext
      mov rdi, other_lost_msg
      mov rsi, r12
      xor rdx, rdx
      mov dl, BYTE [rbx+r12]
      push r12
      push r9
      call printf
      pop r9
      pop r12
      call calculate_results
      mov BYTE [read_buffer], 0


      ; mov byte [rbx+r12], 0

      .nnext:
      jmp _read

      .next12:
      cmp BYTE [read_buffer], '#'
      jne .next2
      mov rbx, [cards_scores_players_current]
      mov rdi, other_stop_msg
      mov rsi, r12
      xor rdx, rdx
      mov dl, BYTE [rbx+r12]
      push r12
      push r10
      call printf
      pop r10
      pop r12
      mov r10, [enders]
      dec BYTE [r10+64]
      mov r10, [enders]
      cmp BYTE [r10+64], 0
      jne .ncalc
      mov rsi, endgame_msg
      call print_str
      inc BYTE [r10+64]
      call calculate_results

      ;   mov rsi, endgame_msg
      ; call print_str 
      jmp _read


      .ncalc:
      mov rdi, left_players_msg
      xor rax, rax
      mov BYTE al, [r10+64]
      
      mov rsi, rax
      push r12
      push rax
      xor rax, rax
      call printf
      pop rax
      pop r12
      mov rdi, [cards_scores_players_current]
      xor rax, rax
      mov BYTE al, [rdi+r12]

      ;///////////////////////////
      ; r12 - name
      ; rax - total
      ; rcx 
      call to_all_stop

          ; mov byte [rbx+r12], 0
      jmp _read

      .next2:
      cmp BYTE [read_buffer], '|'
      jne .next3
      xor rdx, rdx
      mov rdi, user_left_msg
      mov rsi, r12
      mov rbx, [enders]
      dec BYTE [rbx+64]
      mov rbx, [cards_scores_players_current]
      dec BYTE [rbx+64]
      mov BYTE dl, [rbx+64]
      call printf
      mov rbx, [enders]
      cmp BYTE [rbx+64], 1
      jg .ex 
      ; push rcx
      call calculate_results
      ; pop rcx
      .ex:
      call exit


      .next3:
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

    mov rdi, [ids]
    mov rsi, sm1
    mov rdx,1
    mov rax, 65
    syscall
    

    mov rdi, [cards_scores_players_current]
    xor rax, rax
    mov  BYTE al, [rdi+64]
    mov rsi, rax
    mov rdi, ping_msg
    ; call printf


    mov rsi, [message_to_all]
    xor rax, rax
    mov  BYTE al, [rsi]
    cmp rax, '^'
    je .nnn
    mov  BYTE al, [rsi+1]
    cmp rax, r12
    je _write
    .nnn:
    
  
    mov rax, 1
    mov rdi, r12
    mov rsi, [message_to_all]
    mov rdx, 64
    syscall
                      ; mov rsi, [message_to_all]
                      ; mov byte al, [rsi]
                      ; mov byte [sending_dt], al
                      ; mov rdi, sending_dt
                      ; mov rsi, r12
                      ; call printf

    

jmp _write

      
_input:

    mov rbx, [enders]
    xor rax, rax
    mov al, [rbx+64]
    cmp rax, 0 
    je _input

    mov rsi, [message_to_all]
    call input_keyboard

    mov rbx, [enders]
    xor rax, rax
    mov al, [rbx+64]
    cmp rax, 0 
    je _input

    mov rsi, [message_to_all]
    mov byte [rsi+63], 0
    ; call print_str
    xor rax, rax
    ; mov rdi, [address]
    ; mov BYTE al, [rdi]

    ; mov [rdi+1], al
     ;;Открываем семафор
    ; mov rdi, [ids]
    ; mov rsi, sm2
    ; mov rdx,0
    ; mov rax, 65
    xor rcx, rcx
    mov rdi, [cards_scores_players_current]
    mov  BYTE cl, [rdi+64]

    .lp2:
      push rcx
    ; syscall
     ;;Открываем семафор
      mov rdi, [ids]
      mov rsi, sm2
      mov rdx,1
      mov rax, 65
      syscall
      pop rcx
      dec rcx
      cmp rcx, 0
      jne .lp2

    ; mov rdi, [ids]
    ; mov rsi, sm2
    ; mov rdx,1
    ; mov rax, 65
    ; syscall
    ; mov al, [new_status]
    ; call number_str
    ; call print_str
    ;         mov rdi, [address]
    ; mov rax, [rdi]
    ; call number_str
    ; call print_str
jmp _input

new_game:
  mov rsi, [cards_scores_players_current]
  mov rcx, 129
  .lp:
  cmp rcx, 64
  je .nt
  mov byte [rsi+rcx],0 
  .nt:

  loop .lp
  mov rsi, new_game_msg
  call print_str


  mov r10, [enders]
  xor rax, rax
  mov rsi, [cards_scores_players_current]
  mov BYTE al, [rsi+64]
  mov BYTE [r10+64], al
  mov rsi, rax
  mov rdi, reset_amount_msg
  call printf
  mov [max_to21], 0
  mov [max_to21+8], 0
  mov QWORD [message_to_all], 0
  ret

calculate_results:


  
  mov r10, [enders]
  cmp BYTE [r10+64], 0
  je .con
  jl .con

  dec BYTE [r10+64]
    cmp BYTE [r10+64], 0
  je .con
  jl .con
  ret

  .con:

      
    mov rsi, results_msg
  call print_str
  mov rcx, 63
  xor rax, rax
  mov rbx, [cards_scores_players_current]
  .lp:
  push rcx
  cmp byte [rbx+rcx], 0
  je .next
  xor rax, rax
  mov BYTE al, [rbx+rcx]

  ; mov rsi, buffer_help
  ; mov rax, rcx
  ; call number_str
  ; call print_str
  
  ; push rsi
  push rbx
                    push rax
                    xor rdx, rdx
                    mov byte dl, [rbx+rcx]
                    cmp rdx, 21
                    jg .cmx
                    cmp rdx, [max_to21+8]
                    jl .cmx
                    mov [max_to21+8], rdx
                    mov [max_to21], rcx
                    .cmx:
                    ; xor rdx,rdx
                    mov rsi, rcx
                    mov rdi, score_msg
                    ; mov rsi, score_msg
                    call printf
                    ; ; call print_str
                    pop rax
                    pop rbx
                    ; ; pop rsi
  .next:

  pop rcx
  dec rcx
  cmp rcx, -1
  jne .lp
  mov rsi, [max_to21]
  mov rdx, [max_to21+8]
  mov rdi, win_msg

  cmp rdx, 0
  jne .thew
  mov rdi, nowin
  .thew:
  push r10
  call printf
  pop r10
  mov rsi, results2_msg
  call print_str
  push rcx
  push rax
  xor rax, rax
  xor rcx, rcx
  mov rcx, [max_to21]
  mov rax, [max_to21+8]
  call win_all
  pop rax
  pop rcx

  call new_game
  ret
  

to_all_takes:

    mov rdi, [message_to_all]
    mov BYTE [rdi], '!'
    mov rcx, r12
    mov BYTE [rdi+1], cl ; temp
    mov BYTE [rdi+2], dl;temp
    mov BYTE [rdi+3], al;temp
    mov BYTE [rdi+4], 0
                      ; mov rsi, sent_gain_msg
                      ; call print_str

push rdx
push rax
push rcx
push r12
    xor rcx, rcx
    mov rdi, [cards_scores_players_current]
    mov  BYTE cl, [rdi+64]

    .lp2:
      push rcx
    ; syscall
     ;;Открываем семафор
      mov rdi, [ids]
      mov rsi, sm2
      mov rdx,1
      mov rax, 65
      syscall
      pop rcx
      dec rcx
      cmp rcx, 0
      jne .lp2
    pop r12
    pop rcx
    pop rax
    pop rdx

    ret

to_all_stop:
      mov rdi, [message_to_all]
      mov BYTE [rdi], '#'
      mov rcx, r12
      mov BYTE [rdi+1], cl ; temp
      mov BYTE [rdi+2], al;temp
      mov BYTE [rdi+3], 0;temp
      mov BYTE [rdi+4], 0
                          ; mov rsi, sent_stop_msg
                          ; call print_str
  push rdx
  push rax
  push rcx
  push r12
      xor rcx, rcx
      mov rdi, [cards_scores_players_current]
      mov  BYTE cl, [rdi+64]

      .lp2:
        push rcx
      ; syscall
      ;;Открываем семафор

        mov rdi, [ids]
        mov rsi, sm2
        mov rdx,1
        mov rax, 65
        syscall
        pop rcx
        
        dec rcx
        cmp rcx, 0
        jne .lp2



      pop r12
      pop rcx
      pop rax
      pop rdx


      ret
  
win_all:

      mov rdi, [message_to_all]
      mov BYTE [rdi], '^'
      ; mov rcx, r12
      mov BYTE [rdi+1], cl ; temp
      mov BYTE [rdi+2], al;temp
      mov BYTE [rdi+3], 0;temp
      mov BYTE [rdi+4], 0
                            ; mov rsi, sent_stop_msg
                            ; call print_str
  push rdx
  push rax
  push rcx
  push r12
      xor rcx, rcx
      mov rdi, [cards_scores_players_current]
      mov  BYTE cl, [rdi+64]

      .lp2:
        push rcx
      ; syscall
      ;;Открываем семафор
        mov rdi, [ids]
        mov rsi, sm2
        mov rdx,1
        mov rax, 65
        syscall
        pop rcx
        dec rcx
        cmp rcx, 0
        jne .lp2
      pop r12
      pop rcx
      pop rax
      pop rdx
      ret