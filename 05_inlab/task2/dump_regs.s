extern utoa
extern num_buf

section .data
    name_rax: db "rax: "
    len_rax equ $ - name_rax
    name_rbx: db "rbx: "
    len_rbx equ $ - name_rbx
    name_rcx: db "rcx: "
    len_rcx equ $ - name_rcx
    name_rdx: db "rdx: "
    len_rdx equ $ - name_rdx
    name_rsi: db "rsi: "
    len_rsi equ $ - name_rsi
    name_rdi: db "rdi: "
    len_rdi equ $ - name_rdi
    name_rbp: db "rbp: "
    len_rbp equ $ - name_rbp
    name_rsp: db "rsp: "
    len_rsp equ $ - name_rsp
    name_r8: db "r8: "
    len_r8 equ $ - name_r8
    name_r9: db "r9: "
    len_r9 equ $ - name_r9
    name_r10: db "r10: "
    len_r10 equ $ - name_r10
    name_r11: db "r11: "
    len_r11 equ $ - name_r11
    name_r12: db "r12: "
    len_r12 equ $ - name_r12
    name_r13: db "r13: "
    len_r13 equ $ - name_r13
    name_r14: db "r14: "
    len_r14 equ $ - name_r14
    name_r15: db "r15: "
    len_r15 equ $ - name_r15

    tab: db 9
    nl: db 10

    ; printed in this order; must match reg_offsets below
    reg_names: dq name_rax, name_rbx, name_rcx, name_rdx, name_rsi, name_rdi, name_rbp, name_rsp, name_r8, name_r9, name_r10, name_r11, name_r12, name_r13, name_r14, name_r15
    reg_name_lens: dq len_rax, len_rbx, len_rcx, len_rdx, len_rsi, len_rdi, len_rbp, len_rsp, len_r8, len_r9, len_r10, len_r11, len_r12, len_r13, len_r14, len_r15

section .text
    global dump_regs

; dump_regs() -- prints every general-purpose register's current value.
; Modifies no registers and no flags: it looks exactly like a no-op to
; whatever calls it.
dump_regs:
    pushfq
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    ; rsp isn't itself pushed above (it's implicit in the stack pointer), so
    ; reconstruct what it was *before* this function was called: 15 GP
    ; pushes + 1 pushfq (128 bytes) + the return address `call` pushed (8
    ; bytes) = 136 bytes ago.
    mov rax, rsp
    add rax, 136
    push rax

    ; r12 = fixed baseline pointer to our saved snapshot (rax/rbx/etc. are
    ; about to get clobbered by print/utoa, so the loop bookkeeping lives in
    ; r12/r13, which we've *already* saved above and will restore below).
    mov r12, rsp
    xor r13, r13

.print_loop:
    cmp r13, 16
    jge .print_done

    mov rdi, [reg_names + 8*r13]
    mov rsi, [reg_name_lens + 8*r13]
    call .write

    ; offsets into our snapshot, matching reg_names' order: rax,rbx,rcx,rdx,
    ; rsi,rdi,rbp,rsp,r8,r9,r10,r11,r12,r13,r14,r15
    mov rax, r13
    imul rax, 8
    lea rdx, [rel .reg_offsets]
    mov rax, [rdx + rax]
    mov rdi, [r12 + rax]
    call utoa
    mov rsi, rax
    lea rdi, [rel num_buf]
    call .write

    cmp r13, 15
    je .print_nl
    lea rdi, [rel tab]
    mov rsi, 1
    call .write
    jmp .print_next
.print_nl:
    lea rdi, [rel nl]
    mov rsi, 1
    call .write
.print_next:
    inc r13
    jmp .print_loop

.print_done:
    pop rax           ; discard the computed original-rsp value
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    popfq
    ret

; internal helper: writes rsi bytes at rdi to stdout. Not exported --
; dump_regs deliberately doesn't depend on the student's own print(), so it
; stays reliable even while that's still broken.
.write:
    push rax
    push rdi
    push rsi
    push rdx
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    mov rax, 1
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

section .data
.reg_offsets: dq 120, 112, 104, 96, 88, 80, 72, 0, 64, 56, 48, 40, 32, 24, 16, 8
