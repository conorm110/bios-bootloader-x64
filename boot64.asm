[org 0x7e00]

jmp EnterProtectedMode

gdt_nulldesc:
    dd 0
    dd 0
gdt_codedesc:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_datadesc:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    gdt_size:
        dw gdt_end - gdt_nulldesc - 1
        dq gdt_nulldesc

codeseg equ gdt_codedesc - gdt_nulldesc
dataseg equ gdt_datadesc - gdt_nulldesc 
[bits 32]

EditGDT:
    mov [gdt_codedesc + 6], byte 10101111b

    mov [gdt_datadesc + 6], byte 10101111b
    ret

[bits 16]

EnterProtectedMode:
    call EnableA20
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp codeseg:StartProtectedMode

EnableA20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

[bits 32]

DetectCPUID:
    pushfd
    pop eax

    mov ecx, eax

    xor eax, 1 << 21

    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd
    
    xor eax, ecx
    jz NoCPUID
    ret

DetectLongMode:
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz NoLongMode
    ret

NoLongMode:
    hlt ; long mode not supported

NoCPUID:
    hlt ; cpuid not supported

PageTableEntry equ 0x1000

SetUpIdentityPaging:
    mov edi, PageTableEntry
    mov cr3, edi
    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x4003
    add edi, 0x1000

    mov ebx, 0x00000003
    mov ecx, 512

    .SetEntry:
        mov dword [edi], ebx
        add ebx, 0x1000
        add edi, 8
        loop .SetEntry

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

StartProtectedMode:

    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call DetectCPUID
    call DetectLongMode
    call SetUpIdentityPaging
    call EditGDT
    jmp codeseg:Start64Bit

[bits 64]

Start64Bit:
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 500
    rep stosq
    jmp $

times 2048-($-$$) db 0