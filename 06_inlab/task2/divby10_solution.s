section .text
    global _start

; div_by_10(uint64_t n{rdi}) -> uint64_t{rax}
div_by_10:
    mov rax, rdi
    shr rax, 1        ; n / 2
    xor edx, edx      ; clear high half before div
    mov rcx, 5
    div rcx          ; rax / 5
    ret

_start:
    mov rdi, 250
    call div_by_10

    mov rdi, rax
    mov rax, 60
    syscall
