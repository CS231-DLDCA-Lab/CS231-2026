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
    test rdi, rdi
    jnz .recurse
    movsd xmm0, [rel one]
    ret
.recurse:
    mov rax, rdi
    and rax, 1

    sub rsp, 16
    movsd [rsp], xmm0      ; save current base across the recursive call
    mov [rsp+8], rax       ; save parity

    mulsd xmm0, xmm0       ; next base = base * base
    shr rdi, 1              ; next exponent = exponent / 2
    call pow_naive

    mov rax, [rsp+8]
    movsd xmm1, [rsp]
    add rsp, 16

    test rax, rax
    jz .done
    mulsd xmm0, xmm1        ; odd case: multiply back in the saved base
.done:
    ret

; pow_tail(xmm0 = base, rdi = exponent, xmm1 = acc) -> xmm0
; Same result as pow_naive, but written as a tail call (jmp, not call/ret)
; so it doesn't grow the stack with recursion depth.
pow_tail:
    test rdi, rdi
    jnz .recurse
    movsd xmm0, xmm1
    ret
.recurse:
    mov rax, rdi
    and rax, 1
    test rax, rax
    jz .even
    mulsd xmm1, xmm0        ; odd: acc *= base (before base gets squared)
.even:
    mulsd xmm0, xmm0        ; base = base * base
    shr rdi, 1               ; exponent = exponent / 2
    jmp pow_tail

_start:
;   Call pow_naive(base, exponent), truncate the result, and add it to
;   pow_tail(base, exponent, acc=1.0)'s truncated result. Exit with the sum.
;   (Both should independently come out to 57, so the exit code should be 114.)
    movsd xmm0, [rel base]
    mov rdi, [rel exponent]
    call pow_naive
    cvttsd2si rbx, xmm0

    movsd xmm0, [rel base]
    mov rdi, [rel exponent]
    movsd xmm1, [rel one]
    call pow_tail
    cvttsd2si rax, xmm0

    add rbx, rax
    mov rdi, rbx
    mov rax, 60
    syscall
