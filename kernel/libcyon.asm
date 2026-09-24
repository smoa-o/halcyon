[bits 32]
section .text

global ConvertRing
ConvertRing:
    mov eax, [esp+4]    ; ss
    mov ecx, [esp+8]    ; esp
    mov edx, [esp+12]   ; cs
    mov ebp, [esp+16]   ; eip

    cli
    push ebp            ; eip
    push eax            ; ss
    pushfd              ; eflags
    push ecx            ; esp
    push edx            ; cs
    iretd
