section .bss
    buf: resb 256

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    xor eax, eax          ; total
    xor ecx, ecx          ; i
.loop:
    cmp rcx, rsi          ; if i >= n, exit
    jae .done             ; jae means jump if above-or-equal i.e. (uint64_t)i >= (uint64_t)n
    movzx edx, byte [rdi + rcx]  ; we want byte at *(rdi + rcx); use `byte` to only read a byte
                                 ; use movzx to zero extend the upper 56 bits of rdx -- yes i meant rdx not just edx

    ; note: writing to lower 32-bits will automatically zero upper 32 bits of a 64-bit reg
    ; eg: mov edx, 123 ; will zero out upper 32 bits of rdx

    sub dl, '0'           ; dl is lower byte of rdx
    cmp dl, 9
    ja .done              ; (uint8_t) d>9 -> not a digit. explanation is in PS.
    
    imul rax, 10
    add rax, rdx
    inc rcx
    jmp .loop
.done:
    ret

_start:
    ; this is standard code for reading from stdin
    xor eax, eax          ; read
    xor edi, edi          ; fd 0
    lea rsi, [buf]
    mov rdx, 256
    syscall

    ; calling the my_atoi procedure
    lea rdi, [buf]
    mov rsi, rax          ; len = bytes read
    call my_atoi

    mov rdi, rax
    mov rax, 60
    syscall
