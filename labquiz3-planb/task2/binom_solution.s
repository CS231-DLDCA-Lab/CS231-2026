global binom
section .text

binom:
    xor     eax, eax
    cmp     rsi, rdi
    ja      .done               ; k > n: 0
    mov     eax, 1
    cmp     rsi, 0
    je      .done               ; k == 0
    cmp     rsi, rdi
    je      .done               ; k == n

    push    rbx
    push    r12
    push    r13
    mov     rbx, rdi
    dec     rbx                 ; rbx = n - 1
    mov     r12, rsi            ; r12 = k

    mov     rdi, rbx
    mov     rsi, r12
    dec     rsi
    call    binom               ; binom(n - 1, k - 1)
    mov     r13, rax

    mov     rdi, rbx
    mov     rsi, r12
    call    binom               ; binom(n - 1, k)
    add     rax, r13

    pop     r13
    pop     r12
    pop     rbx
.done:
    ret
