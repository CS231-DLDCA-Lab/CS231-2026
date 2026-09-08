extern printf
extern exit

section .rodata
    fmt: db "is_sorted(le)=%ld is_sorted(ge)=%ld count_if(pos)=%ld", 10, 0

section .data
    arr: dd 0, 1, 2, 2, 4, 8
    .end:
    arr_len equ (arr.end-arr)/4

section .text
    global _start

; hint: see setCC commands

; le(int a{edi}, int b{esi}) -> eax (bool: a <= b)
le:

    ret

; ge(int a{edi}, int b{esi}) -> eax (bool: a >= b)
ge:

    ret

; is_positive(int x{edi}) -> eax (bool: x > 0)
is_positive:

    ret

; is_sorted(int* data{rdi}, size_t count{rsi}, FUNC cmp_func{rdx}) -> eax
; cmp_func(a, b) should return true if a is allowed to come before b.
; technically FUNC as a type is bool(*)(int, int) in C but its syntax is ugly
is_sorted:

    ret

; count_if(int* data{rdi}, size_t count{rsi}, FUNC pred{rdx}) -> rax
; technically FUNC as a type is bool(*)(int) in C but its syntax is ugly
count_if:

    ret

_start:
    and rsp, -16
;   call is_sorted(arr, arr_len, le), is_sorted(arr, arr_len, ge), and
;   count_if(arr, arr_len, is_positive) on the same array; printf all three,
;   then exit with 100*is_sorted(le) + 10*is_sorted(ge) + count_if(pos).

    call exit
