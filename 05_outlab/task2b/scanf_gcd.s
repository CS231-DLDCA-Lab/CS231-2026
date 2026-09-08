extern printf
extern exit
extern scanf

section .rodata
    infmt: db "%ld %ld", 0
    outfmt: db "gcd = %ld", 10, 0

section .bss
    val_a: resq 1
    val_b: resq 1

section .text
    global _start

; gcd(int64_t a{rdi}, int64_t b{rsi}) -> rax
gcd:

    ret

_start:
    and rsp, -16
;   Read two numbers with scanf("%ld %ld", &a, &b), and
;   printf("gcd = %ld\n", gcd(a, b)).


    xor edi, edi
    call exit
