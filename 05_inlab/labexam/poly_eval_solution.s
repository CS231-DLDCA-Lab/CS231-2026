section .data
    coeffs:
        dq 1.0, 2.0, 3.0, 4.0
    .end:
    coeffs_len equ (coeffs.end - coeffs)/8

    x_val: dq 2.0

section .text
    global _start

; poly_eval(rdi = coeffs, rsi = N, xmm0 = x) -> xmm0
poly_eval:
    ; ==================== DO NOT EDIT ABOVE THIS LINE ====================
    cmp rsi, 1
    jne .recurse
    movsd xmm0, [rdi]
    ret
.recurse:
    sub rsp, 16
    movsd xmm1, [rdi]
    movsd [rsp], xmm1       ; save coeffs[0] across the recursive call
    movsd [rsp+8], xmm0      ; save x across the recursive call

    add rdi, 8
    dec rsi
    call poly_eval             ; xmm0 = poly_eval(rest of coeffs)

    movsd xmm1, [rsp]
    movsd xmm2, [rsp+8]
    add rsp, 16

    mulsd xmm0, xmm2
    addsd xmm0, xmm1
    ; ==================== DO NOT EDIT BELOW THIS LINE ====================
    ret

_start:
;   Call poly_eval(coeffs, coeffs_len, x_val), truncate the result toward
;   zero, and exit with that as the exit code.
    lea rdi, [coeffs]
    mov rsi, coeffs_len
    movsd xmm0, [x_val]
    call poly_eval
    cvttsd2si rdi, xmm0

    mov rax, 60
    syscall
