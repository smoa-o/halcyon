[bits 32]

section .text

global ConvertRing
ConvertRing:
	pop eax
	pop eax
	pop ecx
	pop edx
	pop ebp
	push ebp
	push edx
	pushfd
	push ecx
	push eax
	iretd
