section .data
    one: dq 1.0

    base: dq 1.5
    exponent: dq 10

    ;; 1.5^10 truncates to 57

section .text
    global _start

; pow_naive(double base{xmm0}, uint64_t exponent{rdi}) -> xmm0
; exponent is a non-negative integer. Uses call/ret recursion.
pow_naive:

    ret

; pow_tail(double base{xmm0}, uint64_t exponent{rdi}, double acc{xmm1} = 1.0) -> xmm0
; Same result as pow_naive, but written as a tail call (jmp, not call/ret)
; so it doesn't grow the stack with recursion depth.
pow_tail:

    ret

_start:
;   Call pow_naive(base, exponent), truncate the result, and add it to
;   pow_tail(base, exponent, acc=1.0)'s truncated result. Exit with the sum.
;   (Both should independently come out to 57, so the exit code should be 114.)

    mov rax, 60
    syscall
