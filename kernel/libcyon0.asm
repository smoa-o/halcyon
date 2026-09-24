[bits 32]
section .text

%if 0
global ConvertRing
ConvertRing:
    mov eax, [esp+4]     ; ss
    mov ecx, [esp+8]     ; esp
    mov edx, [esp+12]    ; cs
    mov ebp, [esp+16]    ; eip

    or eax, 3            ; ss RPL=3  (0x20->0x23)
    or edx, 3            ; cs RPL=3  (0x18->0x1b)

    cli
    push ebp             ; -> eip
    push edx             ; -> cs
    pushfd               ; -> eflags
    push ecx             ; -> esp
    push eax             ; -> ss
    iretd
%endif

%include "kernel/libsys.asm"

global SwitchToRing3
SwitchToRing3:
	pop eax
	push 0x20 | 3 ; |RPL
	push 0x7c00
	push 0x2 ; only bit1
	push 0x18 | 3 ; |RPL
	push eax
	iretd

global kernelmain
kernelmain:
	mov eax, 1
	cpuid
	test edx, 1 << 11
	jz .halt

	mov ecx, 0x174
	mov eax, 8
	xor edx, edx
	wrmsr

	mov ecx, 0x175
	xor edx, edx
	mov eax, kstack_top
	wrmsr

	mov ecx, 0x176
	xor edx, edx
	mov eax, sysenter_entry
	wrmsr

	ret
.halt:
	hlt
	jmp $

sysenter_entry:
	; ecx: return eip
	; edx: user esp
	; eax: syscall number

	push eax
	mov eax, 0x10
	mov ss, ax
	mov ds, ax
	pop eax

	pushad
	call syscall_dispatcher
	popad
	
	xor eax, eax
	mov ax, [0x701]
	
	sysexit

; TO-DO: Dispatch
syscall_dispatcher:
	cmp eax, SysMax
	ja .invalid

	mov ebx, [.syscall_table + eax * 4]
	xor eax, eax
	call ebx

	cmp eax, 0xffff
	jnz .setcode
	ret

.invalid:
	mov byte [0x700], 0x01 ; BADNUM
.setcode:
	mov byte [0x700], 0x00 ; SAFE
	ret
.syscall_table:
	dd Halt
	dd GetErrorCode
SysMax equ 1

section .bss
align 16
kstack: resb 4096
kstack_top:
