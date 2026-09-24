[bits 32]
section .text

%if 0
global ConvertRing
ConvertRing:
    ; C调用: ConvertRing(ss, esp, cs, eip)
    ; 栈: [esp+0]=返回地址 [esp+4]=ss [esp+8]=esp [esp+12]=cs [esp+16]=eip
    mov eax, [esp+4]     ; ss
    mov ecx, [esp+8]     ; esp
    mov edx, [esp+12]    ; cs
    mov ebp, [esp+16]    ; eip

    or eax, 3            ; ss RPL=3  (0x20→0x23)
    or edx, 3            ; cs RPL=3  (0x18→0x1b)

    cli
    push ebp             ; → eip     (iretd弹出第1个)
    push edx             ; → cs      (iretd弹出第2个)
    pushfd               ; → eflags  (iretd弹出第3个)
    push ecx             ; → esp     (iretd弹出第4个)
    push eax             ; → ss      (iretd弹出第5个)
    iretd
%endif

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
	; ecx: returned address
	; edx: user esp
	; eax: syscall number

	mov ax, 0x10
	mov ss, ax

	pushad
	call syscall_dispatcher
	popad
	
	pop eax
	pop ecx
	pop edx
	sysexit

; TODO: Dispatch
syscall_dispatcher: ret

section .bss
align 16
kstack: resb 4096
kstack_top:
