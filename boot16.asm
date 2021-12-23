[org 0x7c00]

mov ah, 0x02          ; read sectors from drive
mov bx, 0x7e00        ; buffer address pointer
mov al, 128           ; number of sectors to read
mov ch, 0x00          ; cylinder number
mov dh, 0x00          ; head number
mov cl, 0x02          ; sector number
int 0x13              ; read disk to memory
jmp 0x7e00            ; jump to the kernel

times 510-($-$$) db 0
dw 0xaa55