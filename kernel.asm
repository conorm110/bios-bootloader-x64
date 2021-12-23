[bits 64]

Start64Bit:
    call graphic
    jmp $

graphic:
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 500
    rep stosq
    ret
