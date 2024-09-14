format ELF
public _start
msg db "Mushkarin", 0xA, "Dmitri", 0xA,"Evgenievich", 0xA, 0


_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 29
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
