[bits 32]

section .text

global usermain
usermain:
	xor eax, eax
	xor ebx, ebx
	mov ecx, .done
	mov edx, esp
	sysenter
.done:
	ret

global sleep
sleep:
	sti
	push eax
	mov eax, [esp+4]
	
	mov dword [0x703], 0
.waiting:
	cmp dword [0x703], eax
	jae .done

	hlt
	jmp .waiting
.done:
	pop eax
	ret
