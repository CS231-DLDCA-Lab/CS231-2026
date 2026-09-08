extern printf
extern exit

section .data
    fmt: db "gcd = %ld", 10, 0

section .bss
    buf: resb 256 ; so much excess space!

section .text
    global _start

; my_strtol_10(const char* str{rdi}, char** str_end{rsi}) -> rax
; write the address of the first character you do not read in [rsi]
my_strtol_10:

    ret

; gcd(int64_t a{rdi}, int64_t b{rsi}) -> rax
gcd:

    ret

_start:
    and rsp, -16
;   Read "A B" (space-separated) from stdin in ONE read syscall, parse both
;   numbers with my_strtol_10 (skipping the separator through strtol),
;   and printf("gcd = %ld\n", gcd(A, B)).

    xor edi, edi
    call exit
