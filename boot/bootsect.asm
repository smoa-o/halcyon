BootDrive      equ 0x0          ; Dynamic

section bootsect vstart=0x7c00
bsmain:
	mov [BootDrive], dl
	mov bp, 0x9000
	mov sp, bp

	mov byte [0x600], 0x7f ; 01111111b

	; Load Tknl
	and byte [0x600], 0xbf ; 10111111b, Close Bit 6

	mov ah, 2
	mov al, 1
	xor ch, ch
	mov cl, 2
	mov dh, 0
	mov dl, [BootDrive]
	mov bx, 0x7e0
	mov es, bx
	xor bx, bx
	int 0x13
	jc .tknl_err

	and byte [0x600], 0xdf ; 11011111, Close Bit 5

	jmp 0x07e0:0x0000

.tknl_err:
	hlt
	jmp $

times 510 - ($-$$) db 0
dw 0xaa55
