section .note.GNU-stack

section .data
    global num_buf
    align 64
    num_buf times 64 db 0


section .text
    global itoa
    global utoa

itoa:
;    `i64` to `ascii`; name of the c function we are implementing here
;    RDI has number we want to print
    mov rax, rdi ; n
    mov rcx, rdi ; n
    xor esi, esi
    neg rcx
    lea rdi, [rel num_buf+0x1f]
    cmovg rax, rcx
    setg sil ; is negative

    mov r8, 0xCCCC_CCCC_CCCC_CCCD

.divloop:
    mov rcx, rax
    mul r8
    shr rdx, 3
    mov rax, rdx
    lea rdx, [rdx + 4*rdx - 0x30/2]
    add rdx, rdx
    sub rcx, rdx
    mov [rdi], cl
    dec rdi
    test rax, rax
    jnz .divloop

    test esi, esi
    lea rax, [rel num_buf+0x1f]
    jz .non_neg
    ; if (was-negative)
    mov dl, '-'
    mov [rdi], dl
    dec rdi

.non_neg:
    movdqu xmm0, [rdi+0x01]
    movdqu xmm1, [rdi+0x11]
    sub rax, rdi
    movdqa [rel num_buf+0x00], xmm0
    movdqa [rel num_buf+0x10], xmm1
    
.finish:
    ret

utoa:
;    `u64` to `ascii`; name of the c function we are implementing here
;    RDI has number we want to print
    mov rax, rdi ; n

    lea rdi, [rel num_buf+0x1f]
    mov r8, 0xCCCC_CCCC_CCCC_CCCD

.divloop:
    mov rcx, rax
    mul r8
    shr rdx, 3
    mov rax, rdx
    lea rdx, [rdx + 4*rdx - 0x30/2]
    add rdx, rdx
    sub rcx, rdx
    mov [rdi], cl
    dec rdi
    test rax, rax
    jnz .divloop

    lea rax, [rel num_buf+0x1f]
    movdqu xmm0, [rdi+0x01]
    movdqu xmm1, [rdi+0x11]
    sub rax, rdi
    movdqa [rel num_buf+0x00], xmm0
    movdqa [rel num_buf+0x10], xmm1
    
.finish:
    ret