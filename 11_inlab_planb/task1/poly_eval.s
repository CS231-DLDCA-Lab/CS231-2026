section .data
    coeffs:
        dq 1, 2, 3, 4
    .end:
    coeffs_len equ (coeffs.end - coeffs)/8

    x_val: dq 2

section .text
    global _start

; poly_eval(int64_t* coeffs{rdi}, size_t N{rsi}, int64_t x{rdx}) -> rax
;   Base case: N == 1, return coeffs[0].
;   Otherwise: rest = poly_eval(coeffs + 8, N - 1, x), return coeffs[0] + x * rest.
;   coeffs[0] and x are needed after the recursive call returns. The call can
;   change every caller-saved register, so save them on the stack first.
poly_eval:
    ; ==================== DO NOT EDIT ABOVE THIS LINE ====================


    ; ==================== DO NOT EDIT BELOW THIS LINE ====================
    ret

_start:
;   Call poly_eval(coeffs, coeffs_len, x_val) and exit with the result as the exit code.
    lea rdi, [rel coeffs]
    mov rsi, coeffs_len
    mov rdx, [rel x_val]
    call poly_eval
    mov rdi, rax

    mov rax, 60
    syscall
