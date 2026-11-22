global dispatch
extern my_write
extern my_exit
extern weighted_avg

section .data
msg_empty:  db "no scores", 10
MSG_LEN     equ $ - msg_empty

section .text

dispatch:
    cmp     rdx, 0
    jne     .avg
    lea     rdi, [rel msg_empty]
    mov     rsi, MSG_LEN
    call    my_write
    mov     rdi, 255
    call    my_exit
.avg:
    call    weighted_avg        ; arguments are already in rdi, rsi, rdx
    mov     rdi, rax
    call    my_exit
