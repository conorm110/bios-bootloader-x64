[org 0x7c00]

mov [BOOT_DISK], dl

mov bp, 0x7c00
mov sp, bp

mov ah, 0x02
mov bx, PROGRAM_SPACE
mov al, 4
mov dl, [BOOT_DISK]
mov ch, 0x00
mov dh, 0x00
mov cl, 0x02

int 0x13

jc disreaderr

jmp PROGRAM_SPACE

PROGRAM_SPACE equ 0x7e00


BOOT_DISK:
    db 0

diskreaderrstr:
    db 'boot16 could not load extended program space',0

disreaderr:
    mov bx, diskreaderrstr ; move the string to be printed into bx
    push ax                ; store ax in stack
    push bx                ; store bx in stack

    ; print the string by looping through and printing characters
    mov ah, 0x0e
    .Loop:
    cmp [bx], byte 0
    je .Exit
        mov al, [bx]
        int 0x10
        inc bx
        jmp .Loop
    .Exit:

    pop ax                 ; restore ax from stack
    pop bx                 ; restore bx from stack

    jmp $
    
times 510-($-$$) db 0

dw 0xaa55