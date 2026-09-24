[bits 32]

section .text

CreateDevStream:
	; cf: isM2D
	; ecx: Count
	; edx: DevNum / Reserved (0)
	; esi: Start Sector / Memory
	; edi: Memory Pos
	
	; [out] cf: isError

	cli
	pushfd

	; 1. set MGC (MaGiC)
	mov dword [edi], 0x001f203a
	mov dword [edi+16], 0x001f203b

	; 2. set IMD (Is Memory to Device)
	jc .cfe
	or  byte [edi+4], 0xff
	jmp .cfend
.cfe:
	and byte [edi+4], 0
.cfend:

	; 3. set ACL (AlloCated Length)
	mov byte [edi+5], cl
	mov byte [edi+6], ch
	shl ecx, 16
	mov byte [edi+7], cl

	; 4. set DEV (DEVice number)
	popfd
	jc .nledx
	xor edx, edx
.nledx:
	mov dword [edi+8], edx

	; 5. set OTPT (OuTPuT)
	mov dword [edi+12], esi
	
	clc
	ret


CreateDevBridge:
	; [stk] DevStream
	; ecx: Count
	; edx: DevNum / Reserved (0)
	; esi: Start Sector / Memory
	
	; [out] cf: isError

	mov edi, [esp+4]

	add edi, 12
	cmp dword [edi+4], 0x001f203b
	jnz .accumulate
	add edi, 4
.call_:
.getImd:
	cmp byte [edi-12], 0
	jnz .lcf
	clc
	jmp .lcfend
.lcf:
	stc
.lcfend:
	call CreateDevStream

	mov dword [edi-16], 0x011f203a
	ret

.accumulate:
	add edi, 12
	cmp dword [edi], 0x001f203b
	jmp .call_
