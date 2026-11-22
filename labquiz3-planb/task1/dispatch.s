; dispatch.s -- Q1 (b)                                               (TODO)

; ---- DO NOT EDIT ----
global dispatch
extern my_write
extern my_exit
extern weighted_avg

section .data
msg_empty:  db "no scores", 10
MSG_LEN     equ $ - msg_empty

section .text
; ---- end of DO NOT EDIT ----

; dispatch(uint64_t* marks{rdi}, uint64_t* credits{rsi}, size_t n{rdx})
dispatch:
    ; TODO
