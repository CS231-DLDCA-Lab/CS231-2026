section .data
    ROWS equ 5
    COLS equ 6

    grid:
        db 0,0,1,0,0,0
        db 0,0,0,0,1,0
        db 0,1,0,0,0,0
        db 0,0,0,0,0,0
        db 1,0,0,1,0,0
    .end:

    ;; number of non-bomb cells with 0 neighboring bombs is 3 by default

%if (ROWS*COLS) != (grid.end-grid)
    %error "Size does not match (ROWS, COLS)"
%endif

section .text
    global _start

_start:
    xor r10, r10        ; safe_count = 0
    xor r8, r8          ; r = 0

.row_loop:
    cmp r8, ROWS
    jge .done
    xor r9, r9          ; c = 0

.col_loop:
    cmp r9, COLS
    jge .row_next

    mov rax, r8
    imul rax, COLS
    add rax, r9
    movzx edx, byte [grid + rax]
    cmp edx, 1
    je .col_next         ; bomb cells don't get a number, skip entirely

    xor r11, r11          ; neighbor bomb count = 0
    mov r12, -1             ; dr = -1
.dr_loop:
    cmp r12, 1
    jg .dr_done
    mov r13, -1               ; dc = -1
.dc_loop:
    cmp r13, 1
    jg .dc_done

    cmp r12, 0
    jne .check_bounds
    cmp r13, 0
    jne .check_bounds
    jmp .dc_next            ; skip the cell itself (dr==0 and dc==0)

.check_bounds:
    mov r14, r8
    add r14, r12               ; nr = r + dr
    mov r15, r9
    add r15, r13                ; nc = c + dc

    cmp r14, 0
    jl .dc_next
    cmp r14, ROWS
    jge .dc_next
    cmp r15, 0
    jl .dc_next
    cmp r15, COLS
    jge .dc_next

    mov rax, r14
    imul rax, COLS
    add rax, r15
    movzx edx, byte [grid + rax]
    cmp edx, 1
    jne .dc_next
    inc r11

.dc_next:
    inc r13
    jmp .dc_loop
.dc_done:
    inc r12
    jmp .dr_loop
.dr_done:

    cmp r11, 0
    jne .col_next
    inc r10

.col_next:
    inc r9
    jmp .col_loop

.row_next:
    inc r8
    jmp .row_loop

.done:
    mov rdi, r10
    mov rax, 60
    syscall
