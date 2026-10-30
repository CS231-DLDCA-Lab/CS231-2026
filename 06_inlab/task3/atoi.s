section .bss
    buf: resb 256

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    ; TODO

    ret

_start:
    ; TODO: read a line from stdin into buf, call my_atoi, exit with the result

    mov rax, 60
    xor edi, edi
    syscall
