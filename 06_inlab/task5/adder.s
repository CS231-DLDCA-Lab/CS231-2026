extern printf
extern exit

section .rodata
    fmt: db "sum = %ld", 10, 0

section .bss
    inbuf: resb 256

section .text
    global _start

; my_atoi(const char* buf{rdi}, size_t len{rsi}) -> uint64_t{rax}
my_atoi:
    ; TODO: copy from Task 3

    ret

_start:
    ; TODO: read two numbers from stdin, add them, then
    ;       printf("sum = %ld\n", sum). exit(0).

    xor edi, edi
    call exit
