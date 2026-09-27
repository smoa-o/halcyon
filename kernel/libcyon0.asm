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

; Structures
struc idt_entry
	.offsetxl   resw 1 ; low
	.selector   resw 1 ; selector
	.zero       resb 1
	.typeattr   resb 1
	.offsetxh   resw 1 ; high
endstruc

struc idtr_t
	.limit    resw 1
	.base     resd 1
endstruc

; Macros
%macro SETIDT 2
	push eax
	mov eax, %2
	mov word [idt + %1*8 + idt_entry.offsetxl], ax
	mov word [idt + %1*8 + idt_entry.selector], 8
	mov word [idt + %1*8 + idt_entry.zero],     0x8e00 ; also set typeattr
	shr eax, 16
	mov word [idt + %1*8 + idt_entry.offsetxh], ax
	pop eax
%endmacro

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

	; schedule
	call init_idt
	call init_pit

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

	mov ebp, [.syscall_table + eax * 4]
	xor eax, eax
	call ebp

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


; IDT
init_idt:
	mov al, 0xff
	out 0x21, al
	out 0xa1, al
	SETIDT 0x20, isr_pit
	lidt [idtr]
	sti
	ret

; Others
init_pit:
	; Init PIC 8259A
	mov al, 0x11
	out 0x20, al ; ICW1
	add al, 0x20-0x11 ; 0x20
	out 0x21, al ; ICW2
	sub al, 0x20-4 ; 4
	out 0x21, al ; ICW3
	sub al, 4-1 ; 1
	out 0x21, al ; ICW4
	
	mov al, 0xfe ; Only IRQ0
	out 0x21, al ; OCW1

	mov al, 0x36
	out 0x43, al
	mov ax, 1193
	out 0x40, al ; low
	mov al, ah
	out 0x40, al

	ret

isr_pit:
	pushad
	call pit_handler
	mov al, 0x20 ; EOI
	out 0x20, al
	popad
	iret

pit_handler:
	; TODO: To somethings...
	xchg bx, bx ; Debug
	inc dword [0x703]
	ret

section .bss

; kstack
align 16
kstack: resb 4096
kstack_top:

; idt
align 8
idt: resb 256 * 8

section .data
idtr:
	istruc idtr_t
		at idtr_t.limit, dw 256+8 - 1
		at idtr_t.base,  dd idt
	iend
