section .data
    coeffs:
        dq 1, 2, 3, 4
    .end:
    coeffs_len equ (coeffs.end - coeffs)/8

    x_val: dq 2

section .text
    global _start

; poly_eval(int64_t* coeffs{rdi}, size_t N{rsi}, int64_t x{rdx}) -> rax
poly_eval:
    ; ==================== DO NOT EDIT ABOVE THIS LINE ====================
    cmp rsi, 1
    jne .recurse
    mov rax, [rdi]          ; base case: one coefficient left
    ret
.recurse:
    mov rax, [rdi]
    push rax                ; save coeffs[0] across the recursive call
    push rdx                ; save x across the recursive call

    add rdi, 8
    dec rsi
    call poly_eval          ; rax = poly_eval(rest of coeffs)

    pop rdx                 ; pop in the reverse order of the pushes
    pop rcx
    imul rax, rdx           ; x * rest
    add rax, rcx            ; coeffs[0] + x * rest
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
