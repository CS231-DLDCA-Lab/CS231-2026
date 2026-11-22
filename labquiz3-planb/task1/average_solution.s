global weighted_avg
section .text

weighted_avg:
    mov     r10, rdx            ; n: div needs rdx
    xor     eax, eax            ; total
    xor     ecx, ecx            ; sum of credits
.loop:
    mov     r8, [rdi]
    mov     r9, [rsi]
    imul    r8, r9
    add     rax, r8
    add     rcx, r9
    add     rdi, 8
    add     rsi, 8
    dec     r10
    jnz     .loop
    xor     edx, edx
    div     rcx
    ret
