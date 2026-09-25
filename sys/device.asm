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

	; 3. set OTPT (OuTPuT)
	push ecx
	mov ecx, esi
	mov byte [edi+5], cl
	mov byte [edi+6], ch
	shl ecx, 16
	mov byte [edi+7], cl
	pop ecx

	; 4. set DEV (DEVice number)
	popfd
	jc .nledx
	mov edx, 0xff
.nledx:
	mov dword [edi+8], edx

	; 5. set ACL (AlloCated Length
	mov dword [edi+12], ecx
	
	clc
	ret


CreateDevBridge:
	; [stk] DevStream
	; ecx: Count
	; edx: DevNum / Reserved (ff)
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


UpdateDevBridge:
	; cf: isM2d
	; ecx: DevNum
	; esi: DevBridge
	; edi: DevStream
	jc .w
.r:
	cmp ecx, 1
	ja .rata
	jmp .rfdc
.w:
	cmp ecx, 1
	ja .wata
	jmp .wfdc

.rata:
	;push ecx
	call .ata

	mov al, 0x20
	inc dx ; offset: 7
	out dx, al

	.wait_drq:
		in al, 0x1f7
		test al, 8
		jz .wait_drq
		test al, 1
		jnz .ata_err

	sub dx, 7 ; offset: 0
	push edx
	;pop ecx
	mov eax, [esi+12]
	mov ebx, 128
	mul ebx ; Count
	mov ecx, ebx
	pop edx

	cld
	rep insd
	
	ret

.ata_err:
	sub dx, 6 ; offset: 1
	in al, dx
	mov byte [0x701], al
	mov eax, 0xffff
	ret
	
.ata:
	call .ata_pre
	pushfd
	push ecx

	; ACL: [edi+12]
	; TODO: Support Read Dword
	mov al, [esi+12]
	sub dx, 5  ; offset: 2
	out dx, al

	; OTPT: [edi+5~7]
	push ebx
	mov ebx, 5
	mov al, [esi+ebx]
	inc dx ; offset: 3
	out dx, al

	inc ebx
	mov al, [esi+ebx]
	inc dx ; offset: 4
	out dx, al

	inc ebx
	mov al, [esi+ebx]
	inc dx ; offset: 5
	out dx, al

	pop ecx
	popfd
	jc .ata_prim
.ata_second:
	sub ecx, 4
	jmp .ata_psend_
.ata_prim:
	sub ecx, 2
.ata_psend_:
	cmp ecx, 0
	jz .ata_master
.ata_slave:
	mov eax, ebx
	shr eax, 24
	and al, 0xf
	or al, 0xf0
	jmp .ata_msend
.ata_master:
	mov eax, ebx
	shr eax, 24
	and al, 0xf
	or al, 0xe0
.ata_msend: ; master / slave end
	inc dx ; offset: 6
	out dx, al
	pop ebx
	
	ret

.ata_pre:
	cmp ecx, 4
	ja .ata_secondary
.ata_primary:
	mov dx, 0x1f0
	stc
	jmp .ata_psend
.ata_secondary:
	mov dx, 0x170
	clc
.ata_psend: ; primary / secondary end
	add dx, 7
	.wait_bsy0:
		in al, dx
		test al, 0x80
		jnz .wait_bsy0
	.wait_drdy1:
		in al, dx
		test al, 0x40
		jz .wait_drdy1
	ret
