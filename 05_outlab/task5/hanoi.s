extern printf
extern exit

section .rodata
    fmt_move: db "Move disk %d from %s to %s", 10, 0
    fmt_count: db "Total moves: %ld", 10, 0
    pole_a: db "A", 0
    pole_b: db "B", 0
    pole_c: db "C", 0

section .data
    move_count: dq 0

section .text
    global _start

; towers_of_hanoi(const char* src{rdi}, const char* dest{rsi}, const char* aux{rdx}, size_t num_discs{rcx})
towers_of_hanoi:

    ret

_start:
    and rsp, -16
;   call towers_of_hanoi(pole_a, pole_c, pole_b, 3), then printf the total
;   move count (should be 2^n - 1), and exit with it.

    call exit
